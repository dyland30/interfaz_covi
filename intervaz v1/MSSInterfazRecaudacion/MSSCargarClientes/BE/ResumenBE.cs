using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MSSCargarClientes.BE
{
    public class ResumenBE
    {
        string _codEstacion;

        public string CodEstacion
        {
            get { return _codEstacion; }
            set { _codEstacion = value; }
        }
        string _serieCaseta;

        public string SerieCaseta
        {
            get { return _serieCaseta; }
            set { _serieCaseta = value; }
        }
        string _turno;

        public string Turno
        {
            get { return _turno; }
            set { _turno = value; }
        }
        int _procesados;

        public int Procesados
        {
            get { return _procesados; }
            set { _procesados = value; }
        }
        int _errores;

        public int Errores
        {
            get { return _errores; }
            set { _errores = value; }
        }

        string _lote;

        public string Lote
        {
            get { return _lote; }
            set { _lote = value; }
        }


    }
}
