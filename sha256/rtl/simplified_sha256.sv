// simplified_sha256
// computes the SHA-256 hash of a NUM_OF_WORDS (20 words = 640 bit) message.
// the message is read from the testbench memory starting at message_addr, and the
// final 256 bit hash {H0..H7} is written back to memory starting at output_addr.
//
// the design follows the FSM flow chart from the project handout:
//   IDLE -> READ -> BLOCK -> COMPUTE -> BLOCK -> ... -> WRITE -> IDLE
//
//   IDLE    : wait for start, load the initial hash values H0-H7
//   READ    : read all 20 message words from memory into the message array
//   BLOCK   : build the next 512 bit block (16 words) in the w window, copy H0-H7 into A-H.
//             if every block is done, go to WRITE instead
//   COMPUTE : do the 64 SHA-256 rounds, one round per clock, then add A-H into H0-H7
//   WRITE   : write H0-H7 to output_addr .. output_addr+7, then go back to IDLE (done = 1)

module simplified_sha256 #(parameter integer NUM_OF_WORDS = 20)(
 input logic  clk, reset_n, start,
 input logic  [15:0] message_addr, output_addr,
 output logic done, mem_clk, mem_we,
 output logic [15:0] mem_addr,
 output logic [31:0] mem_write_data,
 input logic [31:0] mem_read_data);

// FSM state variables
enum logic [2:0] {IDLE, READ, BLOCK, COMPUTE, WRITE} state;

// local variables
logic [31:0] message[NUM_OF_WORDS];     // the whole input message, filled in during READ
logic [31:0] w[16];                     // message schedule window. only 16 W words are needed at
                                        // any time (lecture 14), so w[0] is always the W[t] for the
                                        // current round and the window shifts by one each round
logic [31:0] wt;                        // the next W word (W[t+16]) made by word expansion
logic [31:0] h0, h1, h2, h3, h4, h5, h6, h7;   // hash values H0-H7
logic [31:0] a, b, c, d, e, f, g, h;           // working variables A-H for the 64 rounds
logic [ 7:0] i;                         // round counter in COMPUTE (0-64), word counter in WRITE (0-8)
logic [ 7:0] j;                         // block counter, which 512 bit block we are on
logic [15:0] offset;                    // word address offset, mem_addr = cur_addr + offset
logic [15:0] num_blocks;                // number of 512 bit blocks after padding
logic        read_phase;                // READ sub step. 0 = address just went out, 1 = data is ready
logic        cur_we;                    // memory write enable (registered)
logic [15:0] cur_addr;                  // base address, message_addr for READ and output_addr for WRITE
logic [31:0] cur_write_data;            // data to write into memory (registered)

// SHA256 K constants
parameter int k[0:63] = '{
   32'h428a2f98,32'h71374491,32'hb5c0fbcf,32'he9b5dba5,32'h3956c25b,32'h59f111f1,32'h923f82a4,32'hab1c5ed5,
   32'hd807aa98,32'h12835b01,32'h243185be,32'h550c7dc3,32'h72be5d74,32'h80deb1fe,32'h9bdc06a7,32'hc19bf174,
   32'he49b69c1,32'hefbe4786,32'h0fc19dc6,32'h240ca1cc,32'h2de92c6f,32'h4a7484aa,32'h5cb0a9dc,32'h76f988da,
   32'h983e5152,32'ha831c66d,32'hb00327c8,32'hbf597fc7,32'hc6e00bf3,32'hd5a79147,32'h06ca6351,32'h14292967,
   32'h27b70a85,32'h2e1b2138,32'h4d2c6dfc,32'h53380d13,32'h650a7354,32'h766a0abb,32'h81c2c92e,32'h92722c85,
   32'ha2bfe8a1,32'ha81a664b,32'hc24b8b70,32'hc76c51a3,32'hd192e819,32'hd6990624,32'hf40e3585,32'h106aa070,
   32'h19a4c116,32'h1e376c08,32'h2748774c,32'h34b0bcb5,32'h391c0cb3,32'h4ed8aa4a,32'h5b9cca4f,32'h682e6ff3,
   32'h748f82ee,32'h78a5636f,32'h84c87814,32'h8cc70208,32'h90befffa,32'ha4506ceb,32'hbef9a3f7,32'hc67178f2
};


assign num_blocks = determine_num_blocks(NUM_OF_WORDS);

// Function to determine number of blocks in memory to fetch
// after padding, the message needs:
//   size words of message
//   + 1 word for the "1" padding bit (the message ends on a word boundary, so this is 32'h80000000)
//   + 2 words for the 64 bit message length
// each block holds 16 words, so we round (size + 3) / 16 up.
// rounding up in integer math: ceil(n / 16) = (n + 15) / 16
// example: 20 words -> (20 + 3 + 15) / 16 = 38 / 16 = 2 blocks
function logic [15:0] determine_num_blocks(input logic [31:0] size);
  logic [31:0] total_words;   // message words + padding word + 2 length words
  logic [31:0] blocks;        // 32 bit result of the divide
begin
  total_words = size + 3;
  blocks = (total_words + 15) / 16;
  determine_num_blocks = blocks[15:0];   // 16 bits is way more than enough
end
endfunction


// SHA256 hash round
// one round of the compression function (lecture 14 / handout step 4).
// only A and E get brand new values, the other 6 words just shift over by one.
// note: inside this function w and t are the function inputs (one word and the round number),
// not the module's w window
function logic [255:0] sha256_op(input logic [31:0] a, b, c, d, e, f, g, h, w,
                                 input logic [7:0] t);
    logic [31:0] S1, S0, ch, maj, t1, t2; // internal signals
begin
    S1 = rightrotate(e, 6) ^ rightrotate(e, 11) ^ rightrotate(e, 25);   // SIGMA1(E)
    ch = (e & f) ^ ((~e) & g);                                          // choose: each bit of E picks F (1) or G (0)
    t1 = h + S1 + ch + k[t] + w;                                        // T1 = H + SIGMA1 + Ch + K[t] + W[t]
    S0 = rightrotate(a, 2) ^ rightrotate(a, 13) ^ rightrotate(a, 22);   // SIGMA0(A)
    maj = (a & b) ^ (a & c) ^ (b & c);                                  // majority vote of A, B, C
    t2 = S0 + maj;                                                      // T2 = SIGMA0 + Maj
    sha256_op = {t1 + t2, a, b, c, d + t1, e, f, g};
end
endfunction


// word expansion function
// makes W[t+16] out of 4 older words (lecture 14 message expansion):
//   W16 = W0 + sigma0(W1) + W9 + sigma1(W14)
// the inputs are named by where they sit in the 16 word window
function logic [31:0] word_expansion(input logic [31:0] w0, w1, w9, w14);
    logic [31:0] s0, s1; // internal signals
begin
    s0 = rightrotate(w1, 7) ^ rightrotate(w1, 18) ^ (w1 >> 3);       // sigma0 uses a right SHIFT at the end, not a rotate
    s1 = rightrotate(w14, 17) ^ rightrotate(w14, 19) ^ (w14 >> 10);  // sigma1 also ends with a right SHIFT
    word_expansion = w0 + s0 + w9 + s1;
end
endfunction


// Generate request to memory
// for reading from memory to get original message
// for writing final computed has value
assign mem_clk = clk;
assign mem_addr = cur_addr + offset;
assign mem_we = cur_we;
assign mem_write_data = cur_write_data;

// next W word for the window. w[0], w[1], w[9] and w[14] are W[t], W[t+1], W[t+9] and W[t+14]
assign wt = word_expansion(w[0], w[1], w[9], w[14]);


// Right Rotation Example : right rotate input x by r
// Lets say input x = 1111 ffff 2222 3333 4444 6666 7777 8888
// lets say r = 4
// x >> r  will result in : 0000 1111 ffff 2222 3333 4444 6666 7777
// x << (32-r) will result in : 8888 0000 0000 0000 0000 0000 0000 0000
// final right rotate expression is = (x >> r) | (x << (32-r));
// (0000 1111 ffff 2222 3333 4444 6666 7777) | (8888 0000 0000 0000 0000 0000 0000 0000)
// final value after right rotate = 8888 1111 ffff 2222 3333 4444 6666 7777
// Right rotation function
function logic [31:0] rightrotate(input logic [31:0] x,
                                  input logic [ 7:0] r);
   rightrotate = (x >> r) | (x << (32 - r));
endfunction


// SHA-256 FSM
// Get a BLOCK from the memory, COMPUTE Hash output using SHA256 function
// and write back hash value back to memory
// everything is in one clocked always_ff block with nonblocking assignments, so every
// variable here is a register (no latches)
always_ff @(posedge clk, negedge reset_n)
begin
  if (!reset_n) begin
    cur_we <= 1'b0;
    state <= IDLE;
  end
  else case (state)
    // Initialize hash values h0 to h7 and a to h, other variables and memory we, address offset, etc
    IDLE: begin
       if(start) begin
          // initial hash values H0-H7 (first 32 bits of the square roots of the first 8 primes)
          h0 <= 32'h6a09e667;
          h1 <= 32'hbb67ae85;
          h2 <= 32'h3c6ef372;
          h3 <= 32'ha54ff53a;
          h4 <= 32'h510e527f;
          h5 <= 32'h9b05688c;
          h6 <= 32'h1f83d9ab;
          h7 <= 32'h5be0cd19;

          // point the memory at the first message word and make sure we are reading
          cur_we     <= 1'b0;
          cur_addr   <= message_addr;
          offset     <= 16'd0;
          read_phase <= 1'b0;

          // reset the counters. A-H get loaded from H0-H7 in the BLOCK state
          i <= 8'd0;
          j <= 8'd0;

          state <= READ;
       end
    end

    // read all NUM_OF_WORDS message words from memory, one word every 2 clocks.
    // the memory is synchronous (lecture 15): it registers mem_addr on a clock edge and only
    // then puts that word on mem_read_data. the testbench memory updates mem_read_data on the
    // same edge our FSM samples it, so we hold each address for 2 clocks and only grab the data
    // on the 2nd edge. by then mem_read_data has already settled to the word we asked for, so
    // there is no race between the memory and the FSM
    READ: begin
       if (read_phase == 1'b0) begin
          // 1st clock: address is going out to memory, data is not ready yet
          read_phase <= 1'b1;
       end
       else begin
          // 2nd clock: data for this address is stable, save it
          message[offset] <= mem_read_data;
          read_phase      <= 1'b0;

          if (offset == NUM_OF_WORDS - 1) begin
             // that was the last word, go build the first block
             state <= BLOCK;
          end
          else begin
             // move to the next word address
             offset <= offset + 16'd1;
          end
       end
    end

    // SHA-256 FSM
    // Get a BLOCK from the memory, COMPUTE Hash output using SHA256 function
    // and write back hash value back to memory
    BLOCK: begin
	// Fetch message in 512-bit block size
	// For each of 512-bit block initiate hash value computation
       if (j < num_blocks) begin
          // load the 16 words of block j into the w window (W0-W15)
          if (j == 0) begin
             // block 1 is just the first 16 message words
             for (int n = 0; n < 16; n++) begin
                w[n] <= message[n];
             end
          end
          else begin
             // block 2 is the last 4 message words + padding (same layout as the testbench):
             //   w[0..3]  = message words 16-19
             //   w[4]     = 32'h80000000, the "1" bit right after the message
             //   w[5..14] = zeros
             //   w[15]    = message length in bits (20 * 32 = 640)
             // note: this layout is for the 20 word message size that the project hardcodes
             for (int n = 0; n < 4; n++) begin
                w[n] <= message[16 + n];
             end
             w[4] <= 32'h80000000;
             for (int n = 5; n < 15; n++) begin
                w[n] <= 32'h00000000;
             end
             w[15] <= NUM_OF_WORDS * 32;
          end

          // the working variables start from the current hash values
          a <= h0;
          b <= h1;
          c <= h2;
          d <= h3;
          e <= h4;
          f <= h5;
          g <= h6;
          h <= h7;

          i <= 8'd0;          // start at round 0
          state <= COMPUTE;
       end
       else begin
          // every block has been hashed, so H0-H7 is the final hash. set up the write
          cur_addr <= output_addr;
          offset   <= 16'd0;
          i        <= 8'd0;   // reuse i to count the 8 words we write
          state    <= WRITE;
       end
    end

    // For each block compute hash function
    // Go back to BLOCK stage after each block hash computation is completed and if
    // there are still number of message blocks available in memory otherwise
    // move to WRITE stage
    COMPUTE: begin
	// 64 processing rounds steps for 512-bit block
        if (i < 64) begin
           // one SHA-256 round per clock. w[0] is W[t] for this round (t = i)
           {a, b, c, d, e, f, g, h} <= sha256_op(a, b, c, d, e, f, g, h, w[0], i);

           // slide the window left by one word so w[0] becomes W[t+1] next round,
           // and put the newly expanded word W[t+16] into the last spot.
           // (the last few expanded words are never used, but computing them is harmless)
           for (int n = 0; n < 15; n++) begin
              w[n] <= w[n + 1];
           end
           w[15] <= wt;

           i <= i + 8'd1;
        end
        else begin
           // all 64 rounds are done, add this block's result into the hash values
           h0 <= h0 + a;
           h1 <= h1 + b;
           h2 <= h2 + c;
           h3 <= h3 + d;
           h4 <= h4 + e;
           h5 <= h5 + f;
           h6 <= h6 + g;
           h7 <= h7 + h;

           j <= j + 8'd1;      // next block
           state <= BLOCK;     // BLOCK decides if there is another block or if we write
        end
    end

    // h0 to h7 each are 32 bit hashes, which makes up total 256 bit value
    // h0 to h7 after compute stage has final computed hash value
    // write back these h0 to h7 to memory starting from output_addr
    WRITE: begin
       if (i < 8) begin
          // set up one write per clock: H[i] goes to output_addr + i.
          // the memory does the actual write on the next clock edge
          cur_we <= 1'b1;
          offset <= {8'd0, i};
          case (i)
             8'd0: cur_write_data <= h0;
             8'd1: cur_write_data <= h1;
             8'd2: cur_write_data <= h2;
             8'd3: cur_write_data <= h3;
             8'd4: cur_write_data <= h4;
             8'd5: cur_write_data <= h5;
             8'd6: cur_write_data <= h6;
             8'd7: cur_write_data <= h7;
             default: cur_write_data <= h0;
          endcase
          i <= i + 8'd1;
       end
       else begin
          // on this edge the memory writes H7 (set up last clock), so all 8 words are
          // in memory now. stop writing and go back to IDLE, which raises done
          cur_we <= 1'b0;
          state  <= IDLE;
       end
    end

    default: state <= IDLE;   // safety, should never happen
   endcase
  end

// Generate done when SHA256 hash computation has finished and moved to IDLE state
assign done = (state == IDLE);

endmodule
