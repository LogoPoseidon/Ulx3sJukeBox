#include <stdio.h>
#include <stdlib.h>

// Function to convert a 8-bit PCM file to a hex file
void convert_pcm_to_hex(const char* pcm_filename, const char* hex_filename) {
    FILE *pcm_file, *hex_file;
    __uint8_t pcm_value;
    unsigned int sample_count = 0;

    // Open the PCM file for reading (binary mode)
    pcm_file = fopen(pcm_filename, "rb");
    if (pcm_file == NULL) {
        printf("Error: Could not open PCM file %s\n", pcm_filename);
        return;
    }

    // Open the hex file for writing (text mode)
    hex_file = fopen(hex_filename, "w");
    if (hex_file == NULL) {
        printf("Error: Could not open hex file %s\n", hex_filename);
        fclose(pcm_file);
        return;
    }
    int counter = 0;
    // Read PCM samples (8-bit) and write them to the hex file
    while (fread(&pcm_value, sizeof(__uint8_t), 1, pcm_file)) {
        // Write each 8-bit PCM value as a hexadecimal string to the hex file
        counter++;
        fprintf(hex_file, "%02X", (__uint8_t)pcm_value);
        if(counter==64){
            counter = 0;
            fprintf(hex_file, "\n");
        }
        sample_count++;
    }

    printf("Successfully converted %u PCM samples to hex.\n", sample_count);

    // Close the files
    fclose(pcm_file);
    fclose(hex_file);
}

int main() {
    // Example usage
    const char* pcm_file = "ver.raw";   // Path to the input PCM file
    const char* hex_file = "output.hex";  // Path to the output hex file

    convert_pcm_to_hex(pcm_file, hex_file);

    return 0;
}
