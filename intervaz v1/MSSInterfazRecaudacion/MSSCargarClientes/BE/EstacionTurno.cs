using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MSSCargarClientes.BE
{
    public class EstacionTurno
    {
       
        string _idEstacion;

        public string IdEstacion
        {
            get { return _idEstacion; }
            set { _idEstacion = value; }
        }
        string _turno;

        public string Turno
        {
            get { return _turno; }
            set { _turno = value; }
        }


    }
}
