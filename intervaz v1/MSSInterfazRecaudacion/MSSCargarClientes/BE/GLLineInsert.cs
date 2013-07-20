using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MSSCargarClientes.BE
{
    public class GLLineInsert
    {
        string I_vBACHNUMB {get; set;}
        Int32 I_vJRNENTRY { get; set; }
        Decimal I_vSQNCLINE { get; set; }
        Int32 I_vACTINDX { get; set; }
        Decimal I_vCRDTAMNT { get; set; }
        Decimal I_vDEBITAMT { get; set; }
        string I_vACTNUMST { get; set; }
        string I_vDSCRIPTN { get; set; }
        string I_vORCTRNUM { get; set; }
        string I_vORDOCNUM { get; set; }
        string I_vORMSTRID { get; set; }
        string I_vORMSTRNM { get; set; }
        Int16 I_vORTRXTYP { get; set; }
        Int32 I_vOrigSeqNum { get; set; }
        string I_vORTRXDESC { get; set; }
        string I_vTAXDTLID { get; set; }
        Decimal I_vTAXAMNT { get; set; }
        string I_vTAXACTNUMST { get; set; }
        DateTime I_vDOCDATE { get; set; }
        string I_vCURNCYID { get; set; }
        Decimal I_vXCHGRATE { get; set; }
        string I_vRATETPID { get; set; }
        DateTime I_vEXPNDATE { get; set; }
        DateTime I_vEXCHDATE { get; set; }
        string I_vEXGTBDSC { get; set; }
        string I_vEXTBLSRC { get; set; }
        Int16 I_vRATEEXPR {get; set;}
        Int16 I_vDYSTINCR { get; set; }
        Decimal I_vRATEVARC { get; set; }
        Int16 I_vTRXDTDEF { get; set; }
        Int16 I_vRTCLCMTD { get; set; }
        Int16 I_vPRVDSLMT { get; set; }
        Int16 I_vDATELMTS { get; set; }
        DateTime I_vTIME1 { get; set; }
        Int16 I_vRequesterTrx { get; set; }
        string I_vUSRDEFND1 { get; set; }
        string I_vUSRDEFND2 { get; set; }
        string I_vUSRDEFND3 { get; set; }
        string I_vUSRDEFND4 { get; set; }
        string I_vUSRDEFND5 { get; set; }
        int O_iErrorState { get; set; }
        string oErrString { get; set; }
    }
}
