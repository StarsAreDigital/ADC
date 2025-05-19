#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef union {
    uint8_t bytes[32];  // 32 bytes = 256 bits
    uint32_t words[8];  // 8 32-bit words = 256 bits
} sha256_hash;

static inline uint32_t rightrotate(const uint32_t n, const uint32_t d) {
    return (n >> d) | (n << (32 - d));
}

sha256_hash sha256(const char *msg) {
    static const uint32_t k[64] = {
        0x428a2f98U, 0x71374491U, 0xb5c0fbcfU, 0xe9b5dba5U, 0x3956c25bU,
        0x59f111f1U, 0x923f82a4U, 0xab1c5ed5U, 0xd807aa98U, 0x12835b01U,
        0x243185beU, 0x550c7dc3U, 0x72be5d74U, 0x80deb1feU, 0x9bdc06a7U,
        0xc19bf174U, 0xe49b69c1U, 0xefbe4786U, 0x0fc19dc6U, 0x240ca1ccU,
        0x2de92c6fU, 0x4a7484aaU, 0x5cb0a9dcU, 0x76f988daU, 0x983e5152U,
        0xa831c66dU, 0xb00327c8U, 0xbf597fc7U, 0xc6e00bf3U, 0xd5a79147U,
        0x06ca6351U, 0x14292967U, 0x27b70a85U, 0x2e1b2138U, 0x4d2c6dfcU,
        0x53380d13U, 0x650a7354U, 0x766a0abbU, 0x81c2c92eU, 0x92722c85U,
        0xa2bfe8a1U, 0xa81a664bU, 0xc24b8b70U, 0xc76c51a3U, 0xd192e819U,
        0xd6990624U, 0xf40e3585U, 0x106aa070U, 0x19a4c116U, 0x1e376c08U,
        0x2748774cU, 0x34b0bcb5U, 0x391c0cb3U, 0x4ed8aa4aU, 0x5b9cca4fU,
        0x682e6ff3U, 0x748f82eeU, 0x78a5636fU, 0x84c87814U, 0x8cc70208U,
        0x90befffaU, 0xa4506cebU, 0xbef9a3f7U, 0xc67178f2U};

    uint32_t ha[8] = {0x6a09e667U, 0xbb67ae85U, 0x3c6ef372U, 0xa54ff53aU,
                      0x510e527fU, 0x9b05688cU, 0x1f83d9abU, 0x5be0cd19U};

    const uint64_t length_bytes = strlen(msg);
    const uint64_t padding_bytes = (56 - (length_bytes + 1) % 64) % 64;
    const uint64_t total_bytes = length_bytes + padding_bytes + 9;

    printf("Length: %d\nPadding: %d\n", length_bytes, padding_bytes);

    uint8_t *message = malloc(total_bytes);
    memcpy(message, msg, length_bytes);

    uint64_t ptr = length_bytes;
    message[ptr++] = 1 << 7;

    for (int i = 0; i < padding_bytes; i++) {
        message[ptr++] = 0;
    }

    const uint64_t length_bits_value = length_bytes * 8;
    message[ptr++] = (length_bits_value >> 56) & 0xFF;
    message[ptr++] = (length_bits_value >> 48) & 0xFF;
    message[ptr++] = (length_bits_value >> 40) & 0xFF;
    message[ptr++] = (length_bits_value >> 32) & 0xFF;
    message[ptr++] = (length_bits_value >> 24) & 0xFF;
    message[ptr++] = (length_bits_value >> 16) & 0xFF;
    message[ptr++] = (length_bits_value >> 8) & 0xFF;
    message[ptr++] = length_bits_value & 0xFF;

    for (uint64_t i = 0; i < total_bytes;
         i += 64) {      // for each chunk in message
        uint32_t w[64];  // Message schedule

        for (int j = 0; j < 16;
             j++) {  // load chunk into first 16 words of message schedule
            const uint32_t offset = i + j * 4;
            w[j] = ((uint32_t)(message[offset]) << 24) |
                   ((uint32_t)(message[offset + 1]) << 16) |
                   ((uint32_t)(message[offset + 2]) << 8) |
                   (uint32_t)(message[offset + 3]);
        }

        for (int j = 16; j < 64; j++) {
            const uint32_t s0 = rightrotate(w[j - 15], 7) ^
                                rightrotate(w[j - 15], 18) ^ (w[j - 15] >> 3);
            const uint32_t s1 = rightrotate(w[j - 2], 17) ^
                                rightrotate(w[j - 2], 19) ^ (w[j - 2] >> 10);
            w[j] = w[j - 16] + s0 + w[j - 7] + s1;
        }

        uint32_t vars[8];
        for (int j = 0; j < 8; j++) {
            vars[j] = ha[j];
        }

        for (int j = 0; j < 64; j++) {
            uint32_t S1 = rightrotate(vars[4], 6) ^ rightrotate(vars[4], 11) ^
                          rightrotate(vars[4], 25);
            uint32_t ch = (vars[4] & vars[5]) ^ ((~vars[4]) & vars[6]);
            uint32_t temp1 = vars[7] + S1 + ch + k[j] + w[j];
            uint32_t S0 = rightrotate(vars[0], 2) ^ rightrotate(vars[0], 13) ^
                          rightrotate(vars[0], 22);
            uint32_t maj =
                (vars[0] & vars[1]) ^ (vars[0] & vars[2]) ^ (vars[1] & vars[2]);
            uint32_t temp2 = S0 + maj;

            for (int k = 7; k >= 1; k--) {
                vars[k] = vars[k - 1];
            }
            vars[4] += temp1;
            vars[0] = temp1 + temp2;
        }

        for (int j = 0; j < 8; j++) {
            ha[j] += vars[j];
        }
    }
    free(message);

    sha256_hash hash;
    for (int i = 0; i < 8; i++) {
        hash.words[i] = ha[i];
    }
    return hash;
}

int main(int argc, char *argv[]) {
    sha256_hash hash;
    if (argc > 1) {
        hash = sha256(argv[1]);
    } else {
        hash = sha256(
            "abc");  // should be
                     // ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad
    }

    for (int i = 0; i < 8; i++) {
        printf("%08x", hash.words[i]);
    }
    printf("\n");

    return 0;
}