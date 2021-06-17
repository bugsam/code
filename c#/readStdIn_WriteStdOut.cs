/*
Author: @bugsam
03/17/2021
*/

using System;
using System.IO;

namespace LeitorTerminal
{
    class Program
    {
        static void Main(string[] args)
        {
            TextReader leitor = Console.In;
            string linha = leitor.ReadToEnd();
            Console.WriteLine(linha);
            Console.ReadKey();
        }
    }
}
