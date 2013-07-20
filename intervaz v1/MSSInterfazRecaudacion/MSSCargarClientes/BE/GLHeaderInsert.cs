using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MSSCargarClientes.BE
{
    public class GLHeaderInsert
    {
        string I_vBACHNUMB {get;set;}
        Int32 I_vJRNENTRY { get; set; }
        string I_vREFRENCE { get; set; }
        DateTime I_vTRXDATE { get; set; }
        DateTime I_vRVRSNGDT { get; set; }
        Int16 I_vTRXTYPE { get; set; }
        Decimal I_vSQNCLINE { get; set; }
        Int16 I_vSERIES { get; set; }
        string I_vCURNCYID { get; set; }
        Decimal I_vXCHGRATE { get; set; }
        string I_vRATETPID { get; set; }
        DateTime I_vEXPNDATE { get; set; }
        DateTime I_vEXCHDATE { get; set; }
        string I_vEXGTBDSC { get; set; }
        string I_vEXTBLSRC { get; set; }
        Int16 I_vRATEEXPR { get; set; }
        Int16 I_vDYSTINCR { get; set; }
        Decimal I_vRATEVARC { get; set; }
        Int16 I_vTRXDTDEF { get; set; }
        Int16 I_vRTCLCMTD { get; set; }
        Int16 I_vPRVDSLMT { get; set; }
        Int16 I_vDATELMTS { get; set; }
        DateTime I_vTIME1 { get; set; }
        Int16 I_vRequesterTrx { get; set; }
        string I_vSOURCDOC { get; set; }
        Int16 I_vLedger_ID { get; set; }
        string I_vUSERID { get; set; }
        Int16 I_vAdjustment_Transaction { get; set; }
        string I_vNOTETEXT { get; set; }
        string I_vUSRDEFND1 { get; set; }
        string I_vUSRDEFND2 { get; set; }
        string I_vUSRDEFND3 { get; set; }
        string I_vUSRDEFND4 { get; set; }
        string I_vUSRDEFND5 { get; set; }
        int O_iErrorState { get; set; }
        string oErrString { get; set; }
    }
}
