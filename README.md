LBMIV
=====

Memory Integrity Verification Project



sha256_512bit_input.v is an implementation I downloaded online

sha256_512chunk.v is for processing 512bits chunk

sha256_512chunk_unpipe.v is the unpiplined version

sha256_512top.v is top level

shacompre.v is one of 64 loops

t_sha256_512bit_input.v  is the testbench for sha256_512chunk.v or sha256_512chunk_unpipe.v 

t_shacompre.v is the testbench for shacompre.v 

t_sha256_top.v is test bench for entire sha256 design.

Everything else is from convey sample 
