/*
Author: @bugsam
03/17/2021
*/

using System;
using System.IO;
using System.Windows.Forms;

namespace EditorDeTexto
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            using(Stream entrada = File.Open("texto.txt", FileMode.Open))
            using(TextReader leitor = new StreamReader(entrada))
            {
                string linha = leitor.ReadToEnd();
                folha.Text = linha;
            }
        }

        private void btn_Gravar_Click(object sender, EventArgs e)
        {
            using (Stream saida = File.Open("texto.txt", FileMode.Create))
            using (StreamWriter escritor = new StreamWriter(saida))
            {
                escritor.Write(folha.Text);
            }
        }
    }
}
