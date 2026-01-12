using System;
namespace Reporter {
    class Program {
        static void Main(string[] args) {
            string line;
            while ((line = Console.ReadLine()) != null) {
                Console.WriteLine("[.NET FINAL REPORT] Processed Value: " + line);
            }
        }
    }
}
