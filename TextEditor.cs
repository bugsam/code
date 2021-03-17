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
            //Stream entrada = File.Open("texto.txt", FileMode.Open);
            //StreamReader leitor = new StreamReader(entrada);

            using(Stream entrada = File.Open("texto.txt", FileMode.Open))
            using(StreamReader leitor = new StreamReader(entrada))
            {
                string linha = leitor.ReadToEnd();
                folha.Text = linha;
            }
            /*while(linha != null)
            {
                folha.Text += linha;
                linha = leitor.ReadLine();
            }
            leitor.Close();
            entrada.Close();*/
        }

        private void btn_Gravar_Click(object sender, EventArgs e)
        {
            using (Stream saida = File.Open("texto.txt", FileMode.Create))
            using (StreamWriter escritor = new StreamWriter(saida))
            {
                escritor.Write(folha.Text);
                //escritor.Close();
                //saida.Close();
            }
        }
    }
}
