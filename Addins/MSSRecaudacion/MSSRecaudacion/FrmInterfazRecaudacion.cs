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
using MSSRecaudacion.DAO;
using MSSRecaudacion.BE;
using MSSRecaudacion.BL;

namespace MSSRecaudacion
{
    public partial class FrmInterfazRecaudacion : DexUIForm
    {
        String mensaje = "";
        string codEstacion = "";
        string fecha = "";
        string turno = "";
        string operacion = "";
        public FrmInterfazRecaudacion()
        {
            InitializeComponent();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            try {

                if (cmb_lista_estaciones.SelectedItem != null)
                {
                    this.pictureBox.Image = Properties.Resources.Animation;
                    this.labelProgress.Text = "Cargando Documentos de Venta";
                    codEstacion = cmb_lista_estaciones.SelectedValue.ToString();

                    fecha = dt_fecha.Value.ToString("dd/MM/yyyy");
                    turno = (cmb_turno.SelectedIndex).ToString().PadLeft(2, '0');

                    //establecer operacion
                    operacion = "DOCS";
                    btn_clientes.Enabled = false;
                    ResumenBL.limpiarResumen();
                    this.backgroundWorker.RunWorkerAsync();
                }
                else
                {
                    MessageBox.Show("Debe ingresar todos los campos requeridos", "Advertencia", MessageBoxButtons.OK, MessageBoxIcon.Warning);

                }

            } catch(Exception ex){
                MessageBox.Show(ex.Message,"ERROR",MessageBoxButtons.OK,MessageBoxIcon.Error);
            }

        }

        private void backgroundWorker_DoWork(object sender, DoWorkEventArgs e)
        {
            try
            {
              //  System.Threading.Thread.Sleep(200);
               
                this.mensaje = "";
                if(operacion.Equals("DOCS")){
                    // deshabilitar boton de clientes
                    if (codEstacion.Trim().Equals(""))
                    {
                        codEstacion = "TODOS";
                    }
                    if (turno.Equals("00")){
                        turno = "TODOS";
                    }

                      //  MessageBox.Show(ct.IdEstacion+" "+ct.IdCaseta+" "+ct.Turno);
                        
                    //MessageBox.Show(String.Format("PROC: {0}", String.Format("ejecutarEconnect doc {0} {1} {2}" ,codEstacion,fecha,turno)));

                   DataTable tabla = BDREP.GetInstance().CargarDataTableProc("ejecutarEconnect", "doc " + codEstacion + " " + fecha + " " + turno);
                   if (tabla != null && tabla.Rows.Count > 0)
                   {
                       foreach (DataRow fila in tabla.Rows)
                       {
                           if (fila != null && fila.Field<Object>(0) != null)
                           {
                               mensaje = mensaje + " " + fila.Field<Object>(0).ToString();
                           }
                       }
                   }
                   else { 
                       if(BDREP.GetInstance().MensajeErrorReal!=null){
                           throw BDREP.GetInstance().MensajeErrorReal;
                       }
                   
                   }

                } else if(operacion.Equals("CLI")){
                    //cargar clientes
                    // deshabilitar boton de documentos
                    
                    DataTable tabla = BDREP.GetInstance().CargarDataTableProc("ejecutarEconnect", "cli "+obtenerUsuario());

                    if (tabla != null && tabla.Rows.Count > 0)
                    {
                        foreach (DataRow fila in tabla.Rows)
                        {
                            if (fila != null && fila.Field<Object>(0) != null)
                            {
                                mensaje = mensaje + " " + fila.Field<Object>(0).ToString();
                            }
                        }
                    }
                }
                
            }
            catch (Exception ex)
            {
                //habilitar botones
                btn_documentos.Enabled = true;
                btn_clientes.Enabled = true;
                MessageBox.Show(ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void backgroundWorker_RunWorkerCompleted(object sender, RunWorkerCompletedEventArgs e)
        {
            // termina la carga de documentos de venta

            // crear lote

            this.pictureBox.Image = Properties.Resources.Information;
            this.labelProgress.Text = mensaje;
            //habilitar botones
            btn_documentos.Enabled = true;
            btn_clientes.Enabled = true;

        }

        private void FrmInterfazRecaudacion_Load(object sender, EventArgs e)
        {
            // cargar estaciones
            cargarEstaciones();

            cmb_turno.SelectedIndex = 0;
            lbl_usuario.Text = obtenerUsuario() + " " + obtenerCompanyName() + " " + obtenerFecha();

        }

        private void btn_clientes_Click(object sender, EventArgs e)
        {
            this.pictureBox.Image = Properties.Resources.Animation;
            this.labelProgress.Text = "Cargando Nuevos Clientes";
            //establecer operacion
            operacion = "CLI";
            btn_documentos.Enabled = false;
            this.backgroundWorker.RunWorkerAsync();
        }

        private string obtenerUsuario() {
           return Dynamics.Globals.UserId.Value;
           // return "sa";
        }

        private string obtenerCompanyName() {
           return Dynamics.Globals.CompanyName.Value;
           // return "TWO";
        }
        private string obtenerFecha() {
            return Dynamics.Globals.UserDate.Value.ToShortDateString() + " ";
            //return DateTime.Now.ToString("dd/MM/yyyy");
        }

        private void labelProgress_Click(object sender, EventArgs e)
        {

        }

        private void cargarEstaciones() {

            try {
                List<EstacionesBE> ls = EstacionesBL.obtenerEstacionesPeajeTodas();
                if (ls != null && ls.Count > 0)
                {
                    cmb_lista_estaciones.ValueMember = "LOCNCODE";
                    cmb_lista_estaciones.DisplayMember = "LOCNDSCR";
                    cmb_lista_estaciones.DataSource = ls;


                }
            
            }catch(Exception ex){
                MessageBox.Show("Ha ocurrido un error " + ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);


            }
           
        
        }

        private void cmb_lista_estaciones_SelectedIndexChanged(object sender, EventArgs e)
        {
            //cargarCaseta();
        }
        //private void cargarCaseta() {

        //    try {

        //        List<CasetaBE> ls = CasetaBL.obtenerCasetasPeaje(cmb_lista_estaciones.SelectedValue.ToString());
        //        if (ls != null && ls.Count > 0)
        //        {
        //            cmb_caseta.ValueMember = "IdCaseta";
        //            cmb_caseta.DisplayMember = "Descripcion";
        //            cmb_caseta.DataSource = ls;
        //        }
        //        cmb_caseta.SelectedIndex = 0;

            
        //    }catch(Exception ex){

        //        MessageBox.Show("Ha ocurrido un error "+ex.Message,"Error",MessageBoxButtons.OK,MessageBoxIcon.Error);

        //    }
            

        //}

        private void btn_ver_resumen_Click(object sender, EventArgs e)
        {
            Resumen frm = new Resumen();
            frm.Show();
        }


          

    }
}