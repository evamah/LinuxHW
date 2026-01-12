#include <iostream>
#include <vector>
#include <string>
#include <thread>
#include <chrono>
#include <random>
#include <utility> // For std::pair

// --- ANSI Escape Codes ---
const std::string CSI = "\033[";
const std::string CLEAR_SCREEN = CSI + "2J";
const std::string CURSOR_HOME = CSI + "H";
const std::string HIDE_CURSOR = CSI + "?25l";
const std::string SHOW_CURSOR = CSI + "?25h";
const std::string RESET_COLOR = CSI + "0m";

// Bright Foreground colors for more vivid money
const std::string BRIGHT_RED = CSI + "91m";
const std::string BRIGHT_GREEN = CSI + "92m";
const std::string BRIGHT_YELLOW = CSI + "93m";
const std::string BRIGHT_BLUE = CSI + "94m";
const std::string BRIGHT_MAGENTA = CSI + "95m";
const std::string BRIGHT_CYAN = CSI + "96m";
const std::string BRIGHT_WHITE = CSI + "97m";

// --- Configuration ---
const int SCREEN_WIDTH = 80;
const int SCREEN_HEIGHT = 40;
const int NUM_MONEY_ITEMS = 50;
const std::chrono::milliseconds FRAME_DELAY(100); // 10 frames per second

// --- Money Item Structure ---
struct Money {
    int x;
    int y;
    char character;
    std::string color;
    int speed; // Pixels per frame
};

// --- Random Number Generation ---
std::mt19937 rng(std::random_device{}()); // Mersenne Twister engine seeded by hardware randomness
std::uniform_int_distribution<int> width_dist(1, SCREEN_WIDTH); // x-coordinates (1 to SCREEN_WIDTH)
std::uniform_int_distribution<int> speed_dist(1, 2);           // Falling speed (1 or 2 units per frame)
std::uniform_int_distribution<int> char_type_dist(0, 3);       // For choosing money character type
// Start money items from slightly off-screen top to create a continuous stream
std::uniform_int_distribution<int> initial_y_dist(-SCREEN_HEIGHT / 2, 0);

// Function to get a random money character and its corresponding color
std::pair<char, std::string> getRandomMoneyCharAndColor() {
    int type = char_type_dist(rng);
    switch (type) {
        case 0: return {'$', BRIGHT_GREEN};
        case 1: return {'E', BRIGHT_YELLOW}; // 'E' for Euro
        case 2: return {'Y', BRIGHT_CYAN};   // 'Y' for Yen
        case 3: return {'L', BRIGHT_MAGENTA}; // 'L' for Pound
        default: return {'$', BRIGHT_GREEN}; // Fallback
    }
}

// Initialize a new money item with random properties
Money createNewMoney() {
    std::pair<char, std::string> char_color = getRandomMoneyCharAndColor();
    return {
        width_dist(rng),
        initial_y_dist(rng), // Start at or above the top of the screen
        char_color.first,
        char_color.second,
        speed_dist(rng)
    };
}

int main() {
    // Hide cursor at the start to prevent flickering
    std::cout << HIDE_CURSOR;

    // Initialize money items
    std::vector<Money> money_items;
    money_items.reserve(NUM_MONEY_ITEMS); // Pre-allocate memory
    for (int i = 0; i < NUM_MONEY_ITEMS; ++i) {
        money_items.push_back(createNewMoney());
    }

    // Main animation loop
    while (true) {
        // 1. Clear the screen and move cursor to home
        std::cout << CLEAR_SCREEN << CURSOR_HOME;

        // 2. Render the current frame
        for (const auto& money : money_items) {
            // Only draw if money is within screen bounds
            if (money.y >= 0 && money.y < SCREEN_HEIGHT) {
                // Move cursor to (row, col). ANSI uses 1-based indexing.
                // Row is money.y + 1, Column is money.x + 1
                std::cout << CSI << money.y + 1 << ";" << money.x + 1 << "H";
                std::cout << money.color << money.character << RESET_COLOR;
            }
        }
        std::cout << std::flush; // Flush all output for the frame to ensure it appears at once

        // 3. Sleep for a short duration
        std::this_thread::sleep_for(FRAME_DELAY);

        // 4. Update the state for the next frame
        for (auto& money : money_items) {
            money.y += money.speed;
            // If money falls off the bottom of the screen, reset it to the top
            if (money.y >= SCREEN_HEIGHT) {
                money = createNewMoney();
            }
        }
    }

    // This part is theoretically unreachable due to the infinite loop,
    // but included for completeness if the loop were to be broken.
    // Show cursor again before exiting
    std::cout << SHOW_CURSOR << std::endl;

    return 0;
}
