using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using Microsoft.Dexterity.Bridge;
using Microsoft.Dexterity.Applications;
using Microsoft.Dexterity.Shell;
using MSSRecaudacion.BL;
using MSSRecaudacion.BE;

namespace MSSRecaudacion
{
    public partial class Resumen : DexUIForm
    {
        public Resumen()
        {
            InitializeComponent();
        }

        private void Resumen_Load(object sender, EventArgs e)
        {
            List<ResumenBE> listaResumen = ResumenBL.obtenerResumen();

            dgv_resumen.DataSource = listaResumen;
            lbl_usuario.Text = obtenerUsuario() + " " + obtenerCompanyName() + " " + obtenerFecha();
        }


        private string obtenerUsuario()
        {
            return Dynamics.Globals.UserId.Value;
            // return "sa";
        }

        private string obtenerCompanyName()
        {
            return Dynamics.Globals.CompanyName.Value;
            // return "TWO";
        }
        private string obtenerFecha()
        {
            return Dynamics.Globals.UserDate.Value.ToShortDateString() + " ";
            //return DateTime.Now.ToString("dd/MM/yyyy");
        }

        private void textBox1_TextChanged(object sender, EventArgs e)
        {

        }


    }
}