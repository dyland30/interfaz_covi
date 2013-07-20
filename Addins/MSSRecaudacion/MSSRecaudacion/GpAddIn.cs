using System;
using System.Collections.Generic;
using System.Text;
using Microsoft.Dexterity.Bridge;
using Microsoft.Dexterity.Applications;
using System.Windows.Forms;

namespace MSSRecaudacion
{
    public class GPAddIn : IDexterityAddIn
    {
        // IDexterityAddIn interface
        short MenuTag_Recaudacion;
        private const short DYNAMICS = 0;
        private FrmInterfazRecaudacion frmRecaudacion;



        public void Initialize()
        {

            MenusForVisualStudioTools.Forms.VstmCommandForm.Api.RegisterButton.ClickAfterOriginal += new EventHandler(VSTMCommandFormRegister);
            MenusForVisualStudioTools.Forms.VstmCommandForm.Api.CmdId.ValidateAfterOriginal += new EventHandler(VSTMCommandFormCallback);

        }

        private void VSTMCommandFormRegister(object sender, EventArgs e)
        {
            short ParentTag = 0;
            short Err = 0;

            try
            {
                RegistrarMenu_Recaudacion(ref ParentTag);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "Recaudación");
                if (MenuTag_Recaudacion > 0)
                {
                    Err = MenusForVisualStudioTools.Functions.Unregister.Invoke(ParentTag, MenuTag_Recaudacion);
                    if (Err < 0)
                        MessageBox.Show("Command Interfaz Unregister, error code: " + Convert.ToString(Err), "Recaudación");
                }
            }
        }
        private void VSTMCommandFormCallback(object sender, EventArgs e)
        {
            try
            {
                short Tag = MenusForVisualStudioTools.Functions.Callback.Invoke();
                if (Tag == MenuTag_Recaudacion) OpenMenu_Recaudacion();
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "Interfaz de Recaudacion");
            }
        }

        private void OpenMenu_Recaudacion()
        {
            if (frmRecaudacion == null)
            {
                try
                {
                    frmRecaudacion = new FrmInterfazRecaudacion();
                }
                catch (Exception ex)
                {
                    MessageBox.Show(ex.Message);
                }
            }
            else
            {
                if (frmRecaudacion.Created == false) frmRecaudacion = new FrmInterfazRecaudacion();    
            }
            frmRecaudacion.Show();
            frmRecaudacion.Activate();
        }

        private void RegistrarMenu_Recaudacion(ref short ParentTag)
        {
            short BelowTag = 0;
            short ResID = 0;

            ParentTag = MenusForVisualStudioTools.Functions.GetTagByName.Invoke(DYNAMICS, "Command_Sales", "CL_Sales_Transactions");
            if (ParentTag <= 0) throw new Exception("Parent GetTagByName, error code: " + Convert.ToString(ParentTag));

            BelowTag = MenusForVisualStudioTools.Functions.GetTagByName.Invoke(DYNAMICS, "Command_Sales", "SOP_BulkConfirm");
            if (BelowTag <= 0) throw new Exception("Below GetTagByName, error code: " + Convert.ToString(BelowTag));

            // ResID = MenusForVisualStudioTools.Functions.GetFormResId.Invoke(DYNAMICS, "CM_Reconcile");
           // if (ResID <= 0) throw new Exception("GetFormResId, error code: " + Convert.ToString(ResID));

            //MenuTag_Prueba = MenusForVisualStudioTools.Functions.Register.Invoke(ParentTag, "Conciliación Bancaria", "Conciliación Bancaria", 0, 0, false, false, false, BelowTag, false, false);
            //if (MenuTag_Prueba <= 0) throw new Exception("Command Interfaz RegisterWithSecurity, error code: " + Convert.ToString(MenuTag_Prueba));

            MenuTag_Recaudacion = MenusForVisualStudioTools.Functions.Register.Invoke(ParentTag, "Interfaz de Recaudacion", "Interfaz de Recaudacion", 0, 0, false, false, false, BelowTag, false, false);
            if (MenuTag_Recaudacion <= 0) throw new Exception("Command Interfaz RegisterWithSecurity, error code: " + Convert.ToString(MenuTag_Recaudacion));

            /*
              MenuTag_Recaudacion = MenusForVisualStudioTools.Functions.RegisterWithSecurity.Invoke(ParentTag, "Interfaz de Recaudacion", "Interfaz de Recaudacion", 0, 0, false, false, false, BelowTag, false, false, DYNAMICS, ResID);
            if (MenuTag_Recaudacion <= 0) throw new Exception("Command Interfaz RegisterWithSecurity, error code: " + Convert.ToString(MenuTag_Recaudacion));

             */
        }


    }
}
