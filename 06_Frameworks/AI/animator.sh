#!/bin/bash

API_KEY="AIzaSyCUa4hQhDvexTgadDi26dhHEyCIjoswdPk"

SYSTEM_INSTRUCTION="You are an expert C++ programmer specializing in terminal graphics. Your goal is to create single-file, self-contained C++ programs that generate dynamic, animated visuals in a standard Linux terminal using Standard I/O and ANSI escape codes ONLY. Do not use external libraries like ncurses."

USER_PROMPT="$1"

if [ -z "$USER_PROMPT" ]; then
   exit 1
fi

echo "Asking AI to design the visual C++ program for: '$USER_PROMPT'..."
echo "Use Ctrl+C to stop the animation once it starts."
sleep 2

# --- Construct Prompt ---

DETAILED_PROMPT="Write a complete C++ program to run in a terminal loop. It should visualize: $USER_PROMPT.

Crucial requirements:
1. Use standard libraries only (<iostream>, <vector>, <thread>, <chrono>, etc.).
2. The main loop must:
   a. Clear the screen and move cursor to home using ANSI escape code: cout << \"\\033[2J\\033[H\";
   b. Render the current frame using characters (like '#', '*', 'O').
   c. Sleep for a short duration (e.g., std::this_thread::sleep_for(std::chrono::milliseconds(100)));
   d. Update the state for the next frame.
3. Make the terminal window size roughly 40 rows by 80 columns if fixed sizes are needed.
4. Output ONLY raw code. No markdown formatting."

# --- API Call ---
GENERATE_BODY=$(jq -n \
                --arg system "$SYSTEM_INSTRUCTION" \
                --arg user "$DETAILED_PROMPT" \
                '{
                  contents: [{ role: "user", parts: [{ text: $system }, { text: $user }] }]
                }')


echo ${GENERATE_BODY} > request.json

RESPONSE=$(curl -s -X POST "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${API_KEY}" \
     -H "Content-Type: application/json" \
     -d "$GENERATE_BODY")

echo $RESPONSE >response.json

# --- Extract and Clean Code ---
CODE=$(echo "$RESPONSE" | jq -r '.candidates[0].content.parts[0].text' | sed 's/```cpp//g' | sed 's/```//g')

if [ -z "$CODE" ] || [ "$CODE" == "null" ]; then
    echo "Failed. API Response:"
    echo "$RESPONSE"
    exit 1
fi

echo "$CODE" > temp_visual.cpp

# --- Compile ---
echo "Compiling C++ (this might take a few seconds)..."

g++ -o temp_visual_app temp_visual.cpp

if [ $? -ne 0 ]; then
    echo "Compilation Failed. The AI wrote invalid code this time."
    # Optional: view the failed code
    # cat temp_visual.cpp
    exit 1
fi

echo "Starting Visual App! (Press Ctrl+C to quit)"
sleep 1
# Hide cursor for better visuals before running
echo -ne "\033[?25l"

./temp_visual_app

# --- Cleanup (Runs after Ctrl+C) ---
# Show cursor again
echo -e "\033[?25h"
#rm temp_visual.cpp temp_visual_app