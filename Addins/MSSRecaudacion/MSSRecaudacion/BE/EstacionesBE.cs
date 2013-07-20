using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MSSRecaudacion.BE
{
    public class EstacionesBE
    {
        string _LOCNCODE;

        public string LOCNCODE
        {
            get { return _LOCNCODE; }
            set { _LOCNCODE = value; }
        }
        string _LOCNDSCR;

        public string LOCNDSCR
        {
            get { return _LOCNDSCR; }
            set { _LOCNDSCR = value; }
        }

    }
}
