#!/bin/bash
echo "--- [step 1] Generating Source Code python---"

cat << 'EOF' > gen.py
import sys
for i in range(1, 11):
    print(i)
    sys.stdout.flush()
EOF



cat << 'EOF' > gen.py
import sys
for i in range(1, 11):
    print(i)
    sys.stdout.flush()
EOF

echo "--- [step 2]  CPP -print if %2---"
cat << 'EOF' > filter.cpp
#include <iostream>
int main() {
    int num;
    while(std::cin >> num) {
        if(num % 2 == 0) {
            std::cout << num << std::endl;
        }
    }
    return 0;
}
EOF



# JAVA: Processor (Multiplies by 10)
echo "--- [step 3] JAVA: Processor (Multiplies by 10) ---"
cat << 'EOF' > Processor.java
import java.util.Scanner;
public class Processor {
    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        while(scanner.hasNextInt()) {
            int num = scanner.nextInt();
            System.out.println(num * 10);
        }
    }
}
EOF

echo "--- [step 4]  C# (.NET): Reporter (Formats output) ---"
# C# (.NET): Reporter (Formats output)
dotnet new console -n Reporter > /dev/null 2>&1
cat << 'EOF' > Reporter/Program.cs
using System;
namespace Reporter {
    class Program {
        static void Main(string[] args) {
            string line;
            while ((line = Console.ReadLine()) != null) {
                Console.WriteLine($"[.NET FINAL REPORT] Processed Value: {line}");
            }
        }
    }
}
EOF


# --- 3. COMPILATION ---

echo "---[step 5] Compiling ---"
echo "Compiling C++..."
g++ filter.cpp -o filter
echo "Compiling Java..."
javac Processor.java
echo "Building .NET..."
dotnet build Reporter > /dev/null 2>&1

echo "--- [step 6] Running Pipeline ---"
echo "Flow: Python (1..10) -> C++ (Evens Only) -> Java (x10) -> .NET (Report)"

python3 gen.py | ./filter | java Processor | dotnet run --project Reporter --no-build | tee output.txt

echo "-----------------------------------------------------------"
echo "--- Done ---"