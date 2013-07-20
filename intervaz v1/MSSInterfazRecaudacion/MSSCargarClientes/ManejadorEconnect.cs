using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.Dynamics.GP.eConnect;
using System.Xml;
using Microsoft.Dynamics.GP.eConnect.Serialization;
using System.Xml.Serialization;
using System.IO;
using System.Globalization;
using System.Configuration;
using MSSCargarClientes.BE;
using MSSCargarClientes.BL;

namespace MSSCargarClientes
{

    public static class ManejadorEconnect
    {
        static string sDocumento;
        static string sConnectionString;
        static string EconnectConnectionString = ConfigurationManager.ConnectionStrings["CadenaConexionGP"].ConnectionString;
        static string EconnectDateFormat = ConfigurationManager.AppSettings.Get("FormatoFechaEconnect").ToString();
        static String tipoDocTicketFactura = ConfigurationManager.AppSettings.Get("tip_doc_ticket_factura");
        static String tipoDocTicketBoleta = ConfigurationManager.AppSettings.Get("tip_doc_ticket_boleta");
        static string tipDocFacturaManual = ConfigurationManager.AppSettings.Get("tip_doc_factura_manual");
        static string tipDocBoletaManual = ConfigurationManager.AppSettings.Get("tip_doc_boleta_manual");
        static string tipoDocSobrantes = ConfigurationManager.AppSettings.Get("idTipDocSobrantes");
        static string tipoDocDiscrepancias = ConfigurationManager.AppSettings.Get("idTipDocDiscrepancias");
        static string tipoDocBoletaSobrantes = ConfigurationManager.AppSettings.Get("idTipDocBoletaDiscrepancias");
        static string tipoDocBoletaDiscrepancias = ConfigurationManager.AppSettings.Get("idTipDocBoletaSobrantes");
        
        static string tipoDocumentoVenta = ConfigurationManager.AppSettings.Get("tip_doc_venta");
        static string tipoDocumentoDetraccion = ConfigurationManager.AppSettings.Get("tip_doc_detraccion");

        static Int32 Jrnentry = 0; 
        static string tipoDocConsumoVale = ConfigurationManager.AppSettings.Get("consumoVale");
        static string tipoDocConsumoTelepass = ConfigurationManager.AppSettings.Get("consumoTelepass");
        static CultureInfo culturaInvariante = CultureInfo.InvariantCulture;
        static List<DetalleVentaBE> listaDetracciones = new List<DetalleVentaBE>();
        static string nroArticulo;
        static string nroDocDetraccion;
        static string nroPago;
        static string SopNum;
        static string nroDocVenta;
        static string codDestinoOperacion="";
        static string numero_vale_tag="";
        static string placa = "";
        public static string enviarClientesGP(List<ClienteBE> listaClientes, string idUsuario)
        {
            int ok = 0;
            int err = 0;

            foreach (ClienteBE cli in listaClientes)
            {
                using (eConnectMethods e = new eConnectMethods())
                {
                    try
                    {
                        //crear archivo xml
                        sDocumento = SerializarCliente(cli);
                        // asignar cadena de conexion
                        sConnectionString = EconnectConnectionString;

                     
                        e.CreateEntity(sConnectionString, sDocumento);

                        ClienteBL.insertarClienteGP(cli, idUsuario);
                        // obtener cliente de la tabla intermedia para actualizarlo
                        ClienteBL.modificarEstadoCliente(cli.IdCliente, "P", "");

                        ok++;
                    }
                    catch (eConnectException ex)
                    {
                        // establecer error en cada cliente
                        ClienteBL.modificarEstadoCliente(cli.IdCliente, "E", ex.Message);
                        err++;
                    }
                    catch (Exception ex)
                    {
                        // establecer error en cada cliente
                        ClienteBL.modificarEstadoCliente(cli.IdCliente, "E", ex.Message);
                        err++;
                    }

                }

            }

            return "Se han enviado " + ok.ToString() + " registros, se han encontrado " + err.ToString() + " errores ";

        }

        public static string SerializarCliente(ClienteBE client)
        {
            string cadenaXML = "";
            try
            {
                // Instantiate an eConnectType schema object
                eConnectType eConnect = new eConnectType();

              
                // Instantiate a RMCustomerMasterType schema object
                RMCustomerMasterType customertype = new RMCustomerMasterType();

                // Instantiate a taUpdateCreateCustomerRcd XML node object
                taUpdateCreateCustomerRcd customer = new taUpdateCreateCustomerRcd();

                // Create an XML serializer object
                XmlSerializer serializer = new XmlSerializer(eConnect.GetType());

                // Populate elements of the taUpdateCreateCustomerRcd XML node object
                customer.CUSTNMBR = client.IdCliente;
                customer.CUSTNAME = client.NomCliente;
                customer.SHRTNAME = client.NombreCorto;
                customer.ADDRESS1 = client.Direccion;
                customer.ADRSCODE = ConfigurationManager.AppSettings.Get("idDireccion");
                //customer.CITY = ;
                //customer.ZIPCODE = client.codigozip;
                // crear stored procedure para cargar los demas datos 
                customer.CUSTCLAS = ConfigurationManager.AppSettings.Get("claseCliente");
                //obtener clase de cliente
                ClaseClienteBE claseCliente = ClaseClienteBL.obtenerClaseCliente(customer.CUSTCLAS);
                // llenar los parametros de la clase de cliente
                customer.TAXSCHID = claseCliente.PlanImpuestos;
                customer.SHIPMTHD = claseCliente.MetodoEnvio;
                customer.PYMTRMID = claseCliente.CondicionPago;
                customer.CURNCYID = claseCliente.IdMoneda;
                customer.RMCSHACTNUMST = claseCliente.CuentaEfectivo;
                customer.RMARACTNUMST = claseCliente.CuentaxCobrar;
                customer.RMSLSACTNUMST = claseCliente.CuentaVentas;
                customer.RMCOSACTNUMST = claseCliente.CuentaCostoVenta;
                customer.RMIVACTNUMST = claseCliente.CuentaInventario;
                customer.RMTAKACTNUMST = claseCliente.CuentaCondicionesDtosTomados;
                customer.RMAVACTNUMST = claseCliente.CuentaCondicionesDtosDisponibles;
                customer.RMFCGACTNUMST = claseCliente.CuentaCargosFinancieros;
                customer.RMSORACTNUMST = claseCliente.CuentaDevolucionesPedidosVenta;
                customer.RMWRACTNUMST = claseCliente.CuentaCancelaciones;
                customer.RMOvrpymtWrtoffACTNUMST = claseCliente.CuentaCancelacionesSobrepago;
                customer.SLPRSNID = claseCliente.IdVendedor;
                customer.SALSTERR = claseCliente.IdTerritorio;
                customer.STMTCYCL = claseCliente.CicloEstado;

                // Populate the RMCustomerMasterType schema with the taUpdateCreateCustomerRcd XML node
                customertype.taUpdateCreateCustomerRcd = customer;
                RMCustomerMasterType[] mySMCustomerMaster = { customertype };

                // Populate the eConnectType object with the RMCustomerMasterType schema object
                eConnect.RMCustomerMasterType = mySMCustomerMaster;

                MemoryStream xmlMemoria = new MemoryStream();
                serializer.Serialize(xmlMemoria, eConnect);

                XmlDocument xmlDoc = new XmlDocument();
                xmlMemoria.Position = 0;
                xmlDoc.Load(xmlMemoria);
                xmlMemoria.Close();
                cadenaXML = xmlDoc.OuterXml;

            }
            // catch any errors that occur and display them to the console
            catch (System.Exception ex)
            {
                Console.Write(ex.ToString());
            }
            return cadenaXML;
        }

        public static string enviarDocumentosVentaGP(List<CabeceraVentaBE> listaCabeceras, string nroLote, string codEstacion, string turno)
        {
            int ok = 0; 
            int err = 0;
            listaDetracciones = new List<DetalleVentaBE>();

            foreach (CabeceraVentaBE cabeceraDoc in listaCabeceras)
            {
                using (eConnectMethods e = new eConnectMethods())
                {
                    try
                    {
                        // inicializar entrada de diario en 0
                        Jrnentry = 0;
                        //crear archivo xml
                        // determinar de que caso se trata, 
                        if (cabeceraDoc.TipDoc.Equals(tipoDocTicketFactura) || cabeceraDoc.TipDoc.Equals(tipoDocTicketBoleta)
                            || cabeceraDoc.TipDoc.Equals(tipDocFacturaManual) || cabeceraDoc.TipDoc.Equals(tipDocBoletaManual) )
                        {
                            // tickets boleta y tickets factura pagados
                          
                            sDocumento = SerializarTicket(cabeceraDoc, nroLote);
                           
                        }
                        if (cabeceraDoc.TipDoc.Equals(tipoDocSobrantes) || cabeceraDoc.TipDoc.Equals(tipoDocBoletaSobrantes))
                        {
                            // serializar sobrantes
                            sDocumento = SerializarSobrantes(cabeceraDoc, nroLote);
                        }
                        if (cabeceraDoc.TipDoc.Equals(tipoDocDiscrepancias) || cabeceraDoc.TipDoc.Equals(tipoDocBoletaDiscrepancias))
                        {
                            // serializar discrepancias
                            sDocumento = SerializarDiscrepancias(cabeceraDoc,nroLote);
                        }

                        if (cabeceraDoc.TipDoc.ToUpper().Equals(tipoDocConsumoVale))
                        {
                                // consumo de vales
                               
                                //        sDocumento = SerializarConsumoVale(cabeceraDoc, nroLote);
                                enviarConsumosVale(cabeceraDoc, nroLote);

                        }
                        else if (cabeceraDoc.TipDoc.ToUpper().Equals(tipoDocConsumoTelepass))
                            {
                                // consumo de telepass
                                
                                //sDocumento = SerializarConsumoTelepass(cabeceraDoc, nroLote);
                                enviarConsumosTelepass(cabeceraDoc, nroLote);
                            }

                        // asignar cadena de conexion
                        sConnectionString = EconnectConnectionString;

                        if (!cabeceraDoc.TipDoc.ToUpper().Equals(tipoDocConsumoVale) && !cabeceraDoc.TipDoc.ToUpper().Equals(tipoDocConsumoTelepass))
                        {
                            e.CreateTransactionEntity(sConnectionString, sDocumento);
                        }

                        // obtener los detalles de la tabla intermedia para actualizarlo
                        
                        if (cabeceraDoc.TipDoc.Equals(tipoDocTicketFactura) || cabeceraDoc.TipDoc.Equals(tipoDocTicketBoleta) 
                            || cabeceraDoc.TipDoc.Equals(tipoDocDiscrepancias) || cabeceraDoc.TipDoc.Equals(tipoDocSobrantes)
                            || cabeceraDoc.TipDoc.Equals(tipDocFacturaManual) || cabeceraDoc.TipDoc.Equals(tipDocBoletaManual)
                            || cabeceraDoc.TipDoc.Equals(tipoDocBoletaDiscrepancias) || cabeceraDoc.TipDoc.Equals(tipoDocBoletaSobrantes))
                        
                        {
                            //almacenar en variable temporal
                            string nroDocAux = cabeceraDoc.NroDoc;
                            cabeceraDoc.NroDoc = SopNum;
                            // tickets boleta y tickets factura pagados
                            CabeceraVentaBL.crearDistribucionesCliente(cabeceraDoc);
                            cabeceraDoc.NroDoc = nroDocVenta;

                            // guardar valores definidos por el usuario
                            
                            CabeceraVentaBL.InsertarValoresDefinidosUsuario(3, SopNum, cabeceraDoc.FecProceso.Value, "", "", cabeceraDoc.Turno, cabeceraDoc.CodEstacion, "");
                            
                            CabeceraVentaBL.InsertarFechaProcesoVentanaPago(ConfigurationManager.AppSettings.Get("ExtPagoVentaWindowID"), SopNum, nroPago, 1, cabeceraDoc.FecProceso.Value);
                            // insertar fecha de proceso en el lote de venta
                            CabeceraVentaBL.InsertarFechaProcesoLote(cabeceraDoc.FecProceso.Value, nroLote, ConfigurationManager.AppSettings.Get("OrigenLoteVenta"));

                            // insertar datos tributarios
                            string serie=cabeceraDoc.TipDoc.Trim()+cabeceraDoc.SerieDoc.Trim();
                            if (cabeceraDoc.TipDoc.Equals(tipoDocTicketFactura) || cabeceraDoc.TipDoc.Equals(tipoDocTicketBoleta))
                            {
                                serie = cabeceraDoc.TipDoc.Trim() + "-" + cabeceraDoc.SerieDoc.Trim();
                            }

                            CabeceraVentaBL.InsertarDatosLocalizacion(SopNum,cabeceraDoc.NroDoc,cabeceraDoc.IdCliente,cabeceraDoc.TipoDocSunat,
                                cabeceraDoc.DestinoOperacion, cabeceraDoc.CodEstacion,serie , cabeceraDoc.Fecdoc.Value, ConfigurationManager.AppSettings.Get("idMoneda"), "sa");
                           

                            // regresamos el nro de documento original
                            cabeceraDoc.NroDoc = nroDocAux;
                        }

                        // ASIGNAR DISTRIBUCION CONTABLE DE LOS CONSUMOS EN SOP Y RM
                        if (Jrnentry > 0)
                        {
                            string tipoDistribucionDefecto = ConfigurationManager.AppSettings.Get("tipoDistribucionDefecto");
                            Int16 nroTipoDistribucion = Int16.Parse(tipoDistribucionDefecto);

                            CabeceraVentaBL.crearDistribucionesSOPRM(Jrnentry, nroTipoDistribucion);
                           
                            //agregar turno y codigo de estacion 
                            // turno
                          
                            /*
                            CabeceraVentaBL.InsertarAdicionalesConsumos(ConfigurationManager.AppSettings.Get("ExtConsumoWindowID"), Jrnentry.ToString(), 1, cabeceraDoc.Turno);
                            //codigo de estacion
                            CabeceraVentaBL.InsertarAdicionalesConsumos(ConfigurationManager.AppSettings.Get("ExtConsumoWindowID"), Jrnentry.ToString(), 2, cabeceraDoc.CodEstacion);
                            CabeceraVentaBL.InsertarAdicionalesConsumos(ConfigurationManager.AppSettings.Get("ExtConsumoWindowID"), Jrnentry.ToString(), 3, nroArticulo);
                            CabeceraVentaBL.InsertarAdicionalesConsumos(ConfigurationManager.AppSettings.Get("ExtConsumoWindowID"), Jrnentry.ToString(), 4, numero_vale_tag);
                            CabeceraVentaBL.InsertarAdicionalesConsumos(ConfigurationManager.AppSettings.Get("ExtConsumoWindowID"), Jrnentry.ToString(), 5, placa);
                            CabeceraVentaBL.InsertarAdicionalesConsumos(ConfigurationManager.AppSettings.Get("ExtConsumoWindowID"), Jrnentry.ToString(), 6, cabeceraDoc.NroDocAsociado);
                            */
                             
                            //INSERTAR DATOS EN ADDIN
                            CabeceraVentaBL.guardarDatosAdicionales(Jrnentry, cabeceraDoc.Turno, cabeceraDoc.CodEstacion, nroArticulo, numero_vale_tag, placa, cabeceraDoc.NroDocAsociado);
                            // insertar fecha de proceso en el lote de financiero general
                            CabeceraVentaBL.InsertarFechaProcesoLote(cabeceraDoc.FecProceso.Value, nroLote, ConfigurationManager.AppSettings.Get("OrigenLoteFinGeneral"));

                        }

                        List<DetalleVentaBE> detallesEnviados = DetalleVentaBL.obtenerDetalleDocumentos(cabeceraDoc.TipDoc, cabeceraDoc.SerieDoc, cabeceraDoc.NroDoc);

                        foreach (DetalleVentaBE d in detallesEnviados)
                        {
                            // modificar el estado del detalle
                            // DetalleVentaBL.modificarDetalleDocumento(d.TipDoc, d.Nrodoc, d.Seriedoc, d.Codarticulo, "P", nroLote, "", Jrnentry);
                            //para debug
                            DetalleVentaBL.modificarDetalleDocumento(d.TipDoc, d.Nrodoc, d.Seriedoc, d.Codarticulo, "P", nroLote, "", Jrnentry);
                        }

                        ok++;
                    }
                    catch (eConnectException exp)
                    {
                        // capturar error de econect
                        List<DetalleVentaBE> detallesEnviados = DetalleVentaBL.obtenerDetalleDocumentos(cabeceraDoc.TipDoc, cabeceraDoc.SerieDoc, cabeceraDoc.NroDoc);
                        foreach (DetalleVentaBE d in detallesEnviados)
                        {
                            // modificar el estado del detalle
                            DetalleVentaBL.modificarDetalleDocumento(d.TipDoc, d.Nrodoc, d.Seriedoc, d.Codarticulo, "E", nroLote, exp.Message + exp.StackTrace, Jrnentry);

                            // Console.Write(exp.Message +" "+exp.StackTrace);
                        }

                        err++;
                    }
                    catch (Exception ex)
                    {
                        // capturar error de econect
                        List<DetalleVentaBE> detallesEnviados = DetalleVentaBL.obtenerDetalleDocumentos(cabeceraDoc.TipDoc, cabeceraDoc.SerieDoc, cabeceraDoc.NroDoc);
                        foreach (DetalleVentaBE d in detallesEnviados)
                        {
                            // modificar el estado del detalle
                            DetalleVentaBL.modificarDetalleDocumento(d.TipDoc, d.Nrodoc, d.Seriedoc, d.Codarticulo, "E", nroLote, ex.Message + ex.StackTrace + "", Jrnentry);
                            // Console.Write(ex.Message + " " + ex.StackTrace);
                        }
                        err++;
                    }

                }
            }

            // VERIFICAR SI HAY DETRACCIONES
            // crear funcion serializar detracciones
            //eliminar duplicados en caso haya
            var listaDet = listaDetracciones.Distinct(new ComparadorDetalleVenta());
            listaDetracciones = listaDet.ToList<DetalleVentaBE>();

            if (listaDetracciones.Count > 0)
            {
                // almacenar en el historico todas las detracciones generadas
                // y guardar su estado para poder verificar si se han enviado correctamente
                foreach (DetalleVentaBE det in listaDetracciones)
                {
                    try
                    {
                            eConnectMethods e = new eConnectMethods();
                        
                            nroDocDetraccion = "";
                            string docDetraccion;
                            docDetraccion = SerializarDetraccion(det, nroLote);
                            e.CreateTransactionEntity(EconnectConnectionString, docDetraccion);
                        

                        // guardar detraccion en tabla detalle con estado P

                        det.Estado = "P";
                        det.Observacion = "";
                        det.Nrodoc = nroDocDetraccion;

                        DetalleVentaBL.insertarDetalleDocumento(det);
                        // crear distribucion contable cliente
                        CabeceraVentaBE cab = new CabeceraVentaBE();
                        cab.NroDoc = det.Nrodoc;
                        cab.NomCliente = ConfigurationManager.AppSettings.Get("clienteDetraccion");
                        cab.IdCliente = ConfigurationManager.AppSettings.Get("clienteDetraccion");
                        cab.Turno = det.Turno;
                        cab.CodEstacion = det.Codestacion;
                        cab.FecProceso = det.FecProceso;
                        cab.TipoDocSunat = ConfigurationManager.AppSettings.Get("DOC_TRIBUTARIO_DETRACCION");
                        cab.DestinoOperacion = ConfigurationManager.AppSettings.Get("DETRACCION_DESTINO_OPERACION");
                        cab.SerieDoc = det.Seriedetraccion + det.Seriecaseta;

                        CabeceraVentaBL.crearDistribucionesCliente(cab);
                        CabeceraVentaBL.InsertarValoresDefinidosUsuario(3, nroDocDetraccion, cab.FecProceso.Value, "", "", cab.Turno, cab.CodEstacion, det.Nrodocasociado);
                        CabeceraVentaBL.InsertarFechaProcesoVentanaPago(ConfigurationManager.AppSettings.Get("ExtPagoVentaWindowID"), det.Nrodoc, nroPago, 1, cab.FecProceso.Value);
                        // insertar fecha de proceso en el lote de venta de detraccion
                        CabeceraVentaBL.InsertarFechaProcesoLote(cab.FecProceso.Value, nroLote, ConfigurationManager.AppSettings.Get("OrigenLoteVenta"));
                        
                        //insertar datos de localizacion para la detraccion
                        CabeceraVentaBL.InsertarDatosLocalizacion(nroDocDetraccion, det.Nrodetraccion, cab.IdCliente, cab.TipoDocSunat,
                               cab.DestinoOperacion, cab.CodEstacion,cab.SerieDoc, cab.FecProceso.Value, ConfigurationManager.AppSettings.Get("idMoneda"), "sa");

                    }
                    catch (eConnectException exp)
                    {
                        // guardar detraccion en tabla detalle_old con estado E y la descripcion del error
                        det.Estado = "E";
                        det.Observacion = exp.Message;
                        DetalleVentaBL.insertarDetalleDocumento(det);
                    }
                    catch (Exception ex)
                    {
                        // guardar detraccion en tabla detalle_old con estado E y la descripcion del error
                        //det.Estado = "E";
                        //det.Observacion = ex.Message;
                        //DetalleVentaBL.insertarDetalleDocumento(det);

                        Console.WriteLine(ex.Message);
                    }
                }
            }
            DetalleVentaBL.almacenarHistorico();

            // insertar resumen
            ResumenBE resumen = new ResumenBE();
            resumen.CodEstacion = codEstacion;
            resumen.SerieCaseta = "";
            resumen.Turno = turno;
            resumen.Errores = err;
            resumen.Procesados = ok;
            resumen.Lote = nroLote;
            ResumenBL.InsertarResumen(resumen);

            string mensaje = "Nro Lote " + nroLote + ":  Se han enviado " + ok.ToString() + " registros, se han encontrado " + err.ToString() + " errores";

            if (err > 0)
            {
                mensaje = "Nro Lote " + nroLote + ":  Se han enviado " + ok.ToString() + " registros, se han encontrado " + err.ToString() + " errores. Revisar el informe de errores";

            }


            return mensaje;

        }

        public static string SerializarTicket(CabeceraVentaBE cabeceraDoc, string nroLote)
        {
            string cadenaXML = "";
            String idMoneda = ConfigurationManager.AppSettings.Get("idMoneda");
            Int32 cantidadDecimalesMoneda = CompanyGPBE.ObtenerCantidadDecimalesPorMoneda(idMoneda);

            try
            {
                // obtener detalles de cabecera
                List<DetalleVentaBE> listaDetalles = DetalleVentaBL.obtenerDetalleDocumentos(cabeceraDoc.TipDoc, cabeceraDoc.SerieDoc, cabeceraDoc.NroDoc);
                // crear un array para almacenar las lineas del documento
                taSopLineIvcInsert_ItemsTaSopLineIvcInsert[] detallesGP = new taSopLineIvcInsert_ItemsTaSopLineIvcInsert[listaDetalles.Count];
                int i = 0;
                decimal total = 0;
                foreach (DetalleVentaBE det in listaDetalles)
                {
                    // enviar solamente el precio unitario y la cantidad, dejar a gp que haga el calculo

                    taSopLineIvcInsert_ItemsTaSopLineIvcInsert lineaVenta = new taSopLineIvcInsert_ItemsTaSopLineIvcInsert();
                    // crear numero de articulo
                    string codArticulo = det.Codestacion.Trim().ToUpper() + "." + det.Codarticulo.PadLeft(2, '0');
                    //salesLine.ADDRESS1 = "2345 Main St.";
                    lineaVenta.CUSTNMBR = det.Idcliente;
                    lineaVenta.SOPTYPE = 3;
                    //if (det.TipDoc.Trim().Equals(tipDocBoletaManual) || det.TipDoc.Trim().Equals(tipDocFacturaManual))
                    //{
                    //    lineaVenta.DOCID = det.TipDoc + det.Seriedoc;
                    //}
                    //else {
                    //    lineaVenta.DOCID = det.TipDoc + "-" + det.Seriedoc;
                    //}
                    lineaVenta.DOCID = tipoDocumentoVenta;

                    lineaVenta.ITEMNMBR = codArticulo;
                    lineaVenta.UOFM = ConfigurationManager.AppSettings.Get("unidad");
                    lineaVenta.CURNCYID = idMoneda;
                    // obtener cantidad de decimales de GP
                    lineaVenta.QUANTITY = Math.Round(det.Cantidad.Value, 0, MidpointRounding.AwayFromZero);
                    lineaVenta.UNITPRCE = det.Preuni.Value;
                    lineaVenta.XTNDPRCE = Math.Round(det.Preuni.Value*det.Cantidad.Value, cantidadDecimalesMoneda, MidpointRounding.AwayFromZero);
                    // el sitio va a ser por cada estacion
                    // tendra la siguiente nomenclatura  
                    lineaVenta.LOCNCODE = det.Codestacion.Trim().ToUpper();
                    //NIVEL DE PRECIO
                    lineaVenta.PRCLEVEL = "PEA." + det.Codestacion.Trim().ToUpper();
                    lineaVenta.DOCDATE = DarFormatoFecha(det.Fecdoc.Value);
                    // verificar si tiene detraccion
                    if (det.TotalDetraccion != null && det.Seriedetraccion != null
                        && det.Nrodetraccion != null && det.Seriedetraccion.Trim() != String.Empty
                        && det.Nrodetraccion.Trim() != String.Empty)
                    {
                        // tiene detraccion
                        // crear otra linea de documento para detracciones
                        DetalleVentaBE detraccion = new DetalleVentaBE();
                        detraccion.Codarticulo = ConfigurationManager.AppSettings.Get("articuloDetraccion");
                        detraccion.Nrodetraccion = det.Nrodetraccion;
                        detraccion.Seriedetraccion = det.Seriedetraccion;
                        detraccion.Cantidad = 1;
                        detraccion.Codestacion = det.Codestacion;
                        detraccion.CodLote = nroLote;
                        detraccion.Igv = (Decimal)0;
                       // detraccion.Mtotal = det.TotalDetraccion;
                        detraccion.Preuni = det.TotalDetraccion;
                        detraccion.Total = det.TotalDetraccion;
                        detraccion.TotalDetraccion = det.TotalDetraccion;
                        detraccion.Idcliente = det.Idcliente;
                        detraccion.Fecdoc = det.Fecdoc;
                        detraccion.FecProceso = det.FecProceso;
                        detraccion.TipDoc = ConfigurationManager.AppSettings.Get("DOC_TRIBUTARIO_DETRACCION"); ;
                        detraccion.Nrodocasociado = det.Nrodoc;

                        detraccion.Nrodoc =  det.Nrodetraccion;
                        detraccion.Seriedoc = det.Seriedetraccion;
                        detraccion.Idcliente = det.Idcliente;
                        detraccion.Nomcliente = det.Nomcliente;

                        detraccion.Seriecaseta = det.Seriecaseta;
                        if (det.Sentido != null && det.Sentido != String.Empty)
                            detraccion.Sentido = det.Sentido;
                        else
                            detraccion.Sentido = "";

                        if (det.Placa != null && det.Placa != String.Empty)
                            detraccion.Placa = det.Placa;
                        else
                            detraccion.Placa = "";

                        if (det.Turno != null && det.Turno != String.Empty)
                            detraccion.Turno = det.Turno;
                        else
                            detraccion.Turno = "";

                        if (det.TipoDocsunat != null && det.TipoDocsunat != String.Empty)
                            detraccion.TipoDocsunat = det.TipoDocsunat;
                        else
                            detraccion.TipoDocsunat = "";

                        detraccion.CodLote = nroLote;

                        if (det.FechaVencimientoVale != null)
                            detraccion.FechaVencimientoVale = det.FechaVencimientoVale;
                        else
                            detraccion.FechaVencimientoVale = DateTime.ParseExact(ConfigurationManager.AppSettings.Get("FechaCero"), EconnectDateFormat, culturaInvariante);

                        if (det.NroTag != null && det.NroTag != String.Empty)
                            detraccion.NroTag = det.NroTag;
                        else
                            detraccion.NroTag = "";

                        if (det.DestinoOperacion != null && det.DestinoOperacion != String.Empty)
                            detraccion.DestinoOperacion = det.DestinoOperacion;
                        else
                            detraccion.DestinoOperacion = "";


                        detraccion.NroAsientoCont = 0;

                        // agregar detraccion a la lista de detracciones
                        listaDetracciones.Add(detraccion);
                    }
                    detallesGP[i] = lineaVenta;
                    i++;
                    total += lineaVenta.XTNDPRCE;
                }
                // se debe agregar la información de los impuestos?


                // crear cabecera de documento
                taSopHdrIvcInsert salesHdr = new taSopHdrIvcInsert();

                salesHdr.CREATEDIST = 1;
                salesHdr.SOPTYPE = 3;

                //if (cabeceraDoc.TipDoc.Trim().Equals(tipDocBoletaManual) || cabeceraDoc.TipDoc.Trim().Equals(tipDocFacturaManual))
                //{
                //    salesHdr.DOCID = cabeceraDoc.TipDoc + cabeceraDoc.SerieDoc;
                //}
                //else
                //{
                //    salesHdr.DOCID = cabeceraDoc.TipDoc + "-" + cabeceraDoc.SerieDoc;// de tipo ticket
                //}
                salesHdr.DOCID = tipoDocumentoVenta;
                // obtener número de documento correlativo de gp
                GetNextDocNumbers nextDoc = new GetNextDocNumbers();
                salesHdr.SOPNUMBE = nextDoc.GetNextSOPNumber(IncrementDecrement.Increment, salesHdr.DOCID, SopType.SOPInvoice, EconnectConnectionString);
                //salesHdr.SOPNUMBE = cabeceraDoc.NroDoc; // serie + nro Correlativo
                SopNum = salesHdr.SOPNUMBE;
                salesHdr.BACHNUMB = nroLote; // numero de lote
                salesHdr.LOCNCODE = cabeceraDoc.CodEstacion.Trim().ToUpper(); ;
                salesHdr.DOCDATE = DarFormatoFecha(cabeceraDoc.Fecdoc.Value);
                salesHdr.CUSTNMBR = cabeceraDoc.IdCliente;
                if(cabeceraDoc.NomCliente!=null && cabeceraDoc.NomCliente.Trim()!=String.Empty){
                    salesHdr.CUSTNAME = cabeceraDoc.NomCliente;
                }
                
                salesHdr.CURNCYID = idMoneda;
                salesHdr.CREATETAXES = 1;
                salesHdr.SUBTOTAL = total;
                salesHdr.DOCAMNT = total;
                salesHdr.USINGHEADERLEVELTAXES = 0;
                //salesHdr.CREATEDIST = 1; // 

                //AGREGAR MONTO COBRADO
                salesHdr.PYMTRCVD = total;
                // agregar turno
                salesHdr.USRDEFND3 = cabeceraDoc.Turno;
                // agregar codigo de estacion
                salesHdr.USRDEFND4 = cabeceraDoc.CodEstacion;

                // referencia de contabilidad

                String str_nro_doc;
                if (cabeceraDoc.NroDoc.Trim().Length < 8)
                {
                    str_nro_doc = cabeceraDoc.NroDoc.Trim();
                }
                else {
                    str_nro_doc = cabeceraDoc.NroDoc.Trim().Substring(cabeceraDoc.NroDoc.Trim().Length - 8);
                }
                salesHdr.REFRENCE = cabeceraDoc.SerieDoc + "-" + str_nro_doc + "-" + cabeceraDoc.CodEstacion;
                
                //almacenar nroDocVenta
                nroDocVenta = cabeceraDoc.NroDoc;
                
                

                //salesHdr.PYMTRMID = "Net 30";
                /*
                sopHdrTrx.SUBTOTAL = Math.Round(facturaBE.SubTotal, cantidadDecimalesPorMoneda, MidpointRounding.AwayFromZero);
                sopHdrTrx.TAXAMNT = Math.Round(facturaBE.Impuesto, cantidadDecimalesPorMoneda, MidpointRounding.AwayFromZero);
                sopHdrTrx.DOCAMNT = Math.Round(facturaBE.Total, cantidadDecimalesPorMoneda, MidpointRounding.AwayFromZero);
                 */

                var myNextNumber = new GetNextDocNumbers();
                //agregar pagos
                var pagos = new taCreateSopPaymentInsertRecord_ItemsTaCreateSopPaymentInsertRecord[1];
                taCreateSopPaymentInsertRecord_ItemsTaCreateSopPaymentInsertRecord pago = new taCreateSopPaymentInsertRecord_ItemsTaCreateSopPaymentInsertRecord();
                pago.SOPTYPE = 3;
                pago.SOPNUMBE = salesHdr.SOPNUMBE;
                pago.CUSTNMBR = salesHdr.CUSTNMBR;
                pago.DOCNUMBR = myNextNumber.GetNextRMNumber(IncrementDecrement.Increment, RMPaymentType.RMPayments, EconnectConnectionString);
                pago.DOCDATE = salesHdr.DOCDATE;
                pago.PYMTTYPE = 4;
                pago.DOCAMNT = salesHdr.DOCAMNT;
                // crear idChequera
                //ASIGNAR VARIABLE NROPAGO
                nroPago = pago.DOCNUMBR;

                pago.CHEKBKID = cabeceraDoc.CodEstacion.Trim().ToUpper() + "_EF"; ;

                // agregar el pago al array de pagos
                pagos[0] = pago;

                // crear la transaccion de orden de venta
                SOPTransactionType OrdenVenta = new SOPTransactionType();

                // poblar la orden de venta
                // Populate the schema object with the SOP header and SOP line item objects
                OrdenVenta.taSopLineIvcInsert_Items = detallesGP;
                OrdenVenta.taSopHdrIvcInsert = salesHdr;
                OrdenVenta.taCreateSopPaymentInsertRecord_Items = pagos;

                // Create an array that holds SOPTransactionType objects
                // Populate the array with the SOPTransactionType schema object
                SOPTransactionType[] MySopTransactionType = { OrdenVenta };

                // Create an eConnect XML document object and populate it 
                // with the SOPTransactionType schema object
                eConnectType eConnect = new eConnectType();
                eConnect.SOPTransactionType = MySopTransactionType;
                XmlSerializer serializer = new XmlSerializer(eConnect.GetType());

                MemoryStream xmlMemoria = new MemoryStream();
                serializer.Serialize(xmlMemoria, eConnect);

                XmlDocument xmlDoc = new XmlDocument();
                xmlMemoria.Position = 0;
                xmlDoc.Load(xmlMemoria);
                xmlMemoria.Close();
                cadenaXML = xmlDoc.OuterXml;

            }
            catch (eConnectException ex)
            {
                //notificar de cualquier error de econnect
                Console.WriteLine("ERROR " + ex);
            }
            catch (Exception ex)
            {
                //notificar de cualquier error de econnect
                Console.WriteLine("ERROR " + ex);
            }

            return cadenaXML;
        }

        public static string SerializarDetraccion(DetalleVentaBE det, string nroLote)
        {
            string cadenaXML = "";
            String idMoneda = ConfigurationManager.AppSettings.Get("idMoneda");
            Int32 cantidadDecimalesMoneda = CompanyGPBE.ObtenerCantidadDecimalesPorMoneda(idMoneda);

            try
            {
                // obtener detalles de cabecera
                taSopLineIvcInsert_ItemsTaSopLineIvcInsert[] detallesGP = new taSopLineIvcInsert_ItemsTaSopLineIvcInsert[1];
                taSopLineIvcInsert_ItemsTaSopLineIvcInsert lineaVenta = new taSopLineIvcInsert_ItemsTaSopLineIvcInsert();
                // crear numero de articulo
                string codArticulo = det.Codarticulo;
                //salesLine.ADDRESS1 = "2345 Main St.";
                lineaVenta.CUSTNMBR = ConfigurationManager.AppSettings.Get("clienteDetraccion");
                lineaVenta.SOPTYPE = 3;
               // lineaVenta.DOCID = ConfigurationManager.AppSettings.Get("idTipDocDetraccion") + det.Seriecaseta.Trim();
                lineaVenta.DOCID = tipoDocumentoDetraccion;
                lineaVenta.ITEMNMBR = codArticulo;
                lineaVenta.UOFM = ConfigurationManager.AppSettings.Get("unidad");
                lineaVenta.CURNCYID = idMoneda;
                // obtener cantidad de decimales de GP
                lineaVenta.QUANTITY = Math.Round(det.Cantidad.Value, 0, MidpointRounding.AwayFromZero);
                lineaVenta.UNITPRCE = det.Total.Value;
                lineaVenta.XTNDPRCE = Math.Round(det.Total.Value, cantidadDecimalesMoneda, MidpointRounding.AwayFromZero);
                // el sitio va a ser por cada estacion
                // tendra la siguiente nomenclatura
                //lineaVenta.LOCNCODE = ConfigurationManager.AppSettings.Get("sitio");  
                lineaVenta.LOCNCODE = det.Codestacion.Trim().ToUpper();
                lineaVenta.DOCDATE = DarFormatoFecha(det.Fecdoc.Value);
                // verificar si tiene detraccion 
                lineaVenta.PRCLEVEL = "PEA." + det.Codestacion.Trim().ToUpper();
                detallesGP[0] = lineaVenta;
                // crear cabecera de documento

                // nivel de precio
                
                taSopHdrIvcInsert salesHdr = new taSopHdrIvcInsert();
                GetNextDocNumbers nextNumber = new GetNextDocNumbers();

                salesHdr.SOPNUMBE = nextNumber.GetNextSOPNumber(IncrementDecrement.Increment,tipoDocumentoDetraccion,SopType.SOPInvoice,EconnectConnectionString);
                //salesHdr.SOPNUMBE =  det.Nrodetraccion;
                //CREAR NUMERO CORRELATIVO DE DOCUMENTO
                //salesHdr.SOPNUMBE
                // guardar ese numero correlativo en una variable para asignarlo luego
                nroDocDetraccion = salesHdr.SOPNUMBE;

                salesHdr.CREATEDIST = 1;

                salesHdr.SOPTYPE = 3;
                salesHdr.DOCID = tipoDocumentoDetraccion;
                salesHdr.BACHNUMB = nroLote; // numero de lote
                salesHdr.LOCNCODE = det.Codestacion.Trim().ToUpper(); ;
                salesHdr.DOCDATE = DarFormatoFecha(det.Fecdoc.Value);
                salesHdr.CUSTNMBR = ConfigurationManager.AppSettings.Get("clienteDetraccion");
                salesHdr.CUSTNAME = ConfigurationManager.AppSettings.Get("clienteDetraccion");
                salesHdr.CURNCYID = idMoneda;
                //salesHdr.CREATETAXES = 1;
                salesHdr.SUBTOTAL = det.Total.Value;
                salesHdr.DOCAMNT = det.Total.Value;
                salesHdr.USINGHEADERLEVELTAXES = 0;
                //salesHdr.CREATEDIST = 1; // 
                //AGREGAR MONTO COBRADO
                salesHdr.PYMTRCVD = det.Total.Value;
                salesHdr.ORIGNUMB = det.Nrodocasociado; // numero de documento asociado
                salesHdr.USRDEFND1 = det.Idcliente;// guardar id de cliente
                salesHdr.USRDEFND2 = det.Seriedetraccion + det.Seriedoc; // guardar serie de detraccion
                // agregar turno
                salesHdr.USRDEFND3 = det.Turno;
                // agregar codigo de estacion
                salesHdr.USRDEFND4 = det.Codestacion;
                // agregar referencia de contabilidad

                String str_nro_doc;
                if (det.Nrodetraccion.Trim().Length < 8)
                {
                    str_nro_doc = det.Nrodetraccion.Trim();
                }
                else
                {
                    str_nro_doc = det.Nrodetraccion.Trim().Substring(det.Nrodetraccion.Trim().Length - 8);
                }
                salesHdr.REFRENCE = det.Seriedetraccion + det.Seriecaseta + "-" + str_nro_doc + "-" + det.Codestacion;

                //salesHdr.PYMTRMID = "Net 30";
                /*
                sopHdrTrx.SUBTOTAL = Math.Round(facturaBE.SubTotal, cantidadDecimalesPorMoneda, MidpointRounding.AwayFromZero);
                sopHdrTrx.TAXAMNT = Math.Round(facturaBE.Impuesto, cantidadDecimalesPorMoneda, MidpointRounding.AwayFromZero);
                sopHdrTrx.DOCAMNT = Math.Round(facturaBE.Total, cantidadDecimalesPorMoneda, MidpointRounding.AwayFromZero);
                 */

                var myNextNumber = new GetNextDocNumbers();
                //agregar pagos
                var pagos = new taCreateSopPaymentInsertRecord_ItemsTaCreateSopPaymentInsertRecord[1];
                taCreateSopPaymentInsertRecord_ItemsTaCreateSopPaymentInsertRecord pago = new taCreateSopPaymentInsertRecord_ItemsTaCreateSopPaymentInsertRecord();

                pago.SOPTYPE = 3;
                pago.SOPNUMBE = salesHdr.SOPNUMBE;
                pago.CUSTNMBR = salesHdr.CUSTNMBR;
                pago.DOCNUMBR = myNextNumber.GetNextRMNumber(IncrementDecrement.Increment, RMPaymentType.RMPayments, EconnectConnectionString);
                pago.DOCDATE = salesHdr.DOCDATE;
                pago.PYMTTYPE = 4;
                pago.DOCAMNT = salesHdr.DOCAMNT;
                // crear idChequera
                //ASIGNAR VARIABLE NRO PAGO
                nroPago = pago.DOCNUMBR;
                pago.CHEKBKID = det.Codestacion.Trim().ToUpper() + "_EF_DET"; ;

                // agregar el pago al array de pagos
                pagos[0] = pago;

                // crear la transaccion de orden de venta
                SOPTransactionType OrdenVenta = new SOPTransactionType();

                // poblar la orden de venta
                // Populate the schema object with the SOP header and SOP line item objects
                OrdenVenta.taSopLineIvcInsert_Items = detallesGP;
                OrdenVenta.taSopHdrIvcInsert = salesHdr;
                OrdenVenta.taCreateSopPaymentInsertRecord_Items = pagos;

                // Create an array that holds SOPTransactionType objects
                // Populate the array with the SOPTransactionType schema object
                SOPTransactionType[] MySopTransactionType = { OrdenVenta };

                // Create an eConnect XML document object and populate it 
                // with the SOPTransactionType schema object
                eConnectType eConnect = new eConnectType();
                eConnect.SOPTransactionType = MySopTransactionType;
                XmlSerializer serializer = new XmlSerializer(eConnect.GetType());

                MemoryStream xmlMemoria = new MemoryStream();
                serializer.Serialize(xmlMemoria, eConnect);

                XmlDocument xmlDoc = new XmlDocument();
                xmlMemoria.Position = 0;
                xmlDoc.Load(xmlMemoria);
                xmlMemoria.Close();
                cadenaXML = xmlDoc.OuterXml;

            }
            catch (eConnectException ex)
            {
                //notificar de cualquier error de econnect
                Console.WriteLine("ERROR " + ex);
            }
            catch (Exception ex)
            {
                //notificar de cualquier error de econnect
                Console.WriteLine("ERROR " + ex);
            }

            return cadenaXML;
        }

        public static void enviarConsumosVale(CabeceraVentaBE cabeceraDoc, string nroLote)
        {
            // enviar asientos contables por stored procedure
            String idMoneda = ConfigurationManager.AppSettings.Get("idMoneda");
            Int32 cantidadDecimalesMoneda = CompanyGPBE.ObtenerCantidadDecimalesPorMoneda(idMoneda);
            AsientoContable asiento = new AsientoContable();
            string nroDocAsociado = "";
            if (cabeceraDoc.NroDocAsociado != null)
            {
                nroDocAsociado = cabeceraDoc.NroDocAsociado;
            }

            try
            {
                List<DetalleVentaBE> listaDetalles = DetalleVentaBL.obtenerDetalleDocumentos(cabeceraDoc.TipDoc, cabeceraDoc.SerieDoc, cabeceraDoc.NroDoc);
                foreach (DetalleVentaBE det in listaDetalles)
                {

                    asiento.nroLote = nroLote;
                    asiento.REFRENCE = "CONS. VAL: " + nroDocAsociado;
                    asiento.TRXDATE = cabeceraDoc.FecProceso.Value;
                    asiento.EXCHDATE = DateTime.ParseExact("01/01/1900", "dd/MM/yyyy", CultureInfo.InvariantCulture);
                    asiento.EXPNDATE = DateTime.ParseExact("01/01/1900", "dd/MM/yyyy", CultureInfo.InvariantCulture);
                    asiento.RVRSNGDT = DateTime.ParseExact("01/01/1900", "dd/MM/yyyy", CultureInfo.InvariantCulture);
                    asiento.CURNCYID = idMoneda;
                    asiento.cuentaCredito = ConfigurationManager.AppSettings.Get(det.Codestacion.ToUpper().Trim() + "_CUENTA_VAL_CRED");
                    asiento.cuentaDebito = ConfigurationManager.AppSettings.Get(det.Codestacion.ToUpper().Trim() + "_CUENTA_VAL_DEB");
                    asiento.SOURCDOC = ConfigurationManager.AppSettings.Get("SOURCDOC");
                    asiento.DSCRIPTN = det.Seriedoc + "-" + det.Nrodoc;
                    asiento.monto = det.Total.Value;
                    numero_vale_tag = asiento.DSCRIPTN;

                    Jrnentry= AsientosContablesBL.crearAsientosContables(asiento);
                    nroArticulo = det.Codarticulo.Trim().PadLeft(2,'0');
                    

                }

            }
            catch (Exception ex)
            {
                throw ex;
            }


        }

        public static void enviarConsumosTelepass(CabeceraVentaBE cabeceraDoc, string nroLote)
        {
            // enviar asientos contables por estored procedure
            // enviar asientos contables por stored procedure
            String idMoneda = ConfigurationManager.AppSettings.Get("idMoneda");
            Int32 cantidadDecimalesMoneda = CompanyGPBE.ObtenerCantidadDecimalesPorMoneda(idMoneda);
            AsientoContable asiento = new AsientoContable();
            string nroDocAsociado = "";
            if (cabeceraDoc.NroDocAsociado != null)
            {
                nroDocAsociado = cabeceraDoc.NroDocAsociado;
            }

            try
            {
                List<DetalleVentaBE> listaDetalles = DetalleVentaBL.obtenerDetalleDocumentos(cabeceraDoc.TipDoc, cabeceraDoc.SerieDoc, cabeceraDoc.NroDoc);
                foreach (DetalleVentaBE det in listaDetalles)
                {

                    asiento.nroLote = nroLote;
                    asiento.REFRENCE = "CONS.TEL: " + nroDocAsociado;
                    asiento.TRXDATE = cabeceraDoc.FecProceso.Value;
                    asiento.EXCHDATE = DateTime.ParseExact("01/01/1900", "dd/MM/yyyy", CultureInfo.InvariantCulture);
                    asiento.EXPNDATE = DateTime.ParseExact("01/01/1900", "dd/MM/yyyy", CultureInfo.InvariantCulture);
                    asiento.RVRSNGDT = DateTime.ParseExact("01/01/1900", "dd/MM/yyyy", CultureInfo.InvariantCulture);
                    asiento.CURNCYID = idMoneda;
                    asiento.cuentaDebito = ConfigurationManager.AppSettings.Get(det.Codestacion.ToUpper().Trim() + "_CUENTA_TELEPASS_DEB");
                    asiento.cuentaCredito = ConfigurationManager.AppSettings.Get(det.Codestacion.ToUpper().Trim() + "_CUENTA_TELEPASS_CRED");
                    asiento.SOURCDOC = ConfigurationManager.AppSettings.Get("SOURCDOC");
                    asiento.DSCRIPTN = "PLACA: " + det.Placa + " TAG: " + det.NroTag;
                    asiento.monto = det.Total.Value;
                    numero_vale_tag = det.NroTag;
                    placa = det.Placa;
                    Jrnentry = AsientosContablesBL.crearAsientosContables(asiento);
                    nroArticulo = det.Codarticulo.Trim().PadLeft(2, '0'); ;
                }

            }
            catch (Exception ex)
            {
                throw ex;
            }

        }

        public static string SerializarConsumoVale(CabeceraVentaBE cabeceraDoc, string nroLote)
        {
            string cadenaXML = "";
            String idMoneda = ConfigurationManager.AppSettings.Get("idMoneda");
            Int32 cantidadDecimalesMoneda = CompanyGPBE.ObtenerCantidadDecimalesPorMoneda(idMoneda);

            try
            {
                // obtener detalle de consumos

                List<DetalleVentaBE> listaDetalles = DetalleVentaBL.obtenerDetalleDocumentos(cabeceraDoc.TipDoc, cabeceraDoc.SerieDoc, cabeceraDoc.NroDoc);
                //CREAR TRANSACCION FINANCIERA
                taGLTransactionHeaderInsert glTransaccionHdr = new taGLTransactionHeaderInsert();

                taGLTransactionLineInsert_ItemsTaGLTransactionLineInsert[] asientosContables = new taGLTransactionLineInsert_ItemsTaGLTransactionLineInsert[listaDetalles.Count * 2];

                // obtener jentry
                string nroDocAsociado = "";
                if (cabeceraDoc.NroDocAsociado != null)
                {
                    nroDocAsociado = cabeceraDoc.NroDocAsociado;
                }

                GetNextDocNumbers nextDoc = new GetNextDocNumbers();
                Jrnentry = Int32.Parse(nextDoc.GetNextGLJournalEntryNumber(IncrementDecrement.Increment, EconnectConnectionString));
                glTransaccionHdr.BACHNUMB = nroLote;
                glTransaccionHdr.JRNENTRY = Jrnentry;
                glTransaccionHdr.REFRENCE = "CONS. VAL: " + nroDocAsociado;
                glTransaccionHdr.TRXDATE = DarFormatoFecha(cabeceraDoc.Fecdoc.Value);
                glTransaccionHdr.TRXTYPE = 0; // 0=Regular; 1=Reversing
                glTransaccionHdr.SERIES = 2; // 2=Financial;
                glTransaccionHdr.CURNCYID = idMoneda;
                //glTransaccionHdr.RATETPID = glTrx.RATETPID;

                glTransaccionHdr.SOURCDOC = ConfigurationManager.AppSettings.Get("SOURCDOC");
                //glTransaccionHdr.SQNCLINE
                //glTransaccionHdr.EXGTBDSC = glTrx.EXGTBDSC;
                //glTransaccionHdr.USERID = glTrx.USERID;
                //corregir el error del formato de fechas
                glTransaccionHdr.EXCHDATE = ConfigurationManager.AppSettings.Get("FechaCero");
                glTransaccionHdr.EXPNDATE = ConfigurationManager.AppSettings.Get("FechaCero");
                glTransaccionHdr.DATELMTS = 0;
                glTransaccionHdr.TRXDTDEF = 0;

                glTransaccionHdr.RVRSNGDT = ConfigurationManager.AppSettings.Get("FechaCero");

                int i = 0;

                foreach (DetalleVentaBE det in listaDetalles)
                {
                    // crear distribucion contable
                    taGLTransactionLineInsert_ItemsTaGLTransactionLineInsert asientocuentaDebito = new taGLTransactionLineInsert_ItemsTaGLTransactionLineInsert();
                    asientocuentaDebito.ACTNUMST = ConfigurationManager.AppSettings.Get(det.Codestacion.ToUpper().Trim() + "_CUENTA_VAL_DEB");
                    asientocuentaDebito.DEBITAMT = det.Total.Value;
                    asientocuentaDebito.CRDTAMNT = (Decimal)0.00;
                    asientocuentaDebito.JRNENTRY = Jrnentry;
                    asientocuentaDebito.BACHNUMB = nroLote;
                    asientocuentaDebito.DSCRIPTN = det.Seriedoc + "-" + det.Nrodoc;
                    //asientocuentaDebito.ORDOCNUM = det.Nrodocasociado;
                    asientocuentaDebito.SQNCLINE = (Decimal)(i + 1);
                    //buscar documento en gp para establecer como documento de referencia
                    asientocuentaDebito.CURNCYID = idMoneda;

                    nroArticulo = det.Codarticulo.Trim().PadLeft(2, '0');

                    //cuentaDebito.DOCNUMBR 
                    // agregar asiento a array de asientos
                    asientosContables[i] = asientocuentaDebito;
                    i++;

                    taGLTransactionLineInsert_ItemsTaGLTransactionLineInsert asientocuentaCredito = new taGLTransactionLineInsert_ItemsTaGLTransactionLineInsert();
                    asientocuentaCredito.ACTNUMST = ConfigurationManager.AppSettings.Get(det.Codestacion.ToUpper().Trim() + "_CUENTA_VAL_CRED");
                    asientocuentaCredito.DEBITAMT = (Decimal)0.00;
                    asientocuentaCredito.CRDTAMNT = det.Total.Value;
                    asientocuentaCredito.JRNENTRY = Jrnentry;
                    asientocuentaCredito.BACHNUMB = nroLote;
                    asientocuentaCredito.DSCRIPTN = det.Seriedoc + "-" + det.Nrodoc;
                    asientocuentaCredito.SQNCLINE = (Decimal)(i + 1);
                    //buscar documento en gp para establecer como documento de referencia
                    asientocuentaCredito.CURNCYID = idMoneda;
                    //cuentaDebito.DOCNUMBR 
                    // agregar asiento a array de asientos
                    asientosContables[i] = asientocuentaCredito;
                    i++;
                }

                GLTransactionType glTransactionType = new GLTransactionType();
                glTransactionType.taGLTransactionHeaderInsert = glTransaccionHdr;
                glTransactionType.taGLTransactionLineInsert_Items = asientosContables;

                GLTransactionType[] myGLTransactionType = { glTransactionType };

                eConnectType eConnect = new eConnectType();

                eConnect.GLTransactionType = myGLTransactionType;

                XmlSerializer serializer = new XmlSerializer(eConnect.GetType());

                MemoryStream xmlMemoria = new MemoryStream();
                serializer.Serialize(xmlMemoria, eConnect);

                XmlDocument xmlDoc = new XmlDocument();
                xmlMemoria.Position = 0;
                xmlDoc.Load(xmlMemoria);
                xmlMemoria.Close();
                cadenaXML = xmlDoc.OuterXml;

            }
            catch (eConnectException ex)
            {
                //notificar de cualquier error de econnect
                Console.WriteLine("ERROR " + ex);
            }
            catch (Exception ex)
            {
                //notificar de cualquier error de econnect
                Console.WriteLine("ERROR " + ex);
            }
            return cadenaXML;

        }

        public static string SerializarConsumoTelepass(CabeceraVentaBE cabeceraDoc, string nroLote)
        {
            string cadenaXML = "";
            String idMoneda = ConfigurationManager.AppSettings.Get("idMoneda");
            Int32 cantidadDecimalesMoneda = CompanyGPBE.ObtenerCantidadDecimalesPorMoneda(idMoneda);
            try
            {
                // obtener detalle de consumos

                List<DetalleVentaBE> listaDetalles = DetalleVentaBL.obtenerDetalleDocumentos(cabeceraDoc.TipDoc, cabeceraDoc.SerieDoc, cabeceraDoc.NroDoc);
                //CREAR TRANSACCION FINANCIERA
                taGLTransactionHeaderInsert glTransaccionHdr = new taGLTransactionHeaderInsert();

                taGLTransactionLineInsert_ItemsTaGLTransactionLineInsert[] asientosContables = new taGLTransactionLineInsert_ItemsTaGLTransactionLineInsert[listaDetalles.Count * 2];
                // obtener documento asociado
                // obtener jentry
                string nroDocAsociado = "";

                if (cabeceraDoc.NroDocAsociado != null)
                {
                    nroDocAsociado = cabeceraDoc.NroDocAsociado;
                }

                // obtener jentry
                GetNextDocNumbers nextDoc = new GetNextDocNumbers();
                Jrnentry = Int32.Parse(nextDoc.GetNextGLJournalEntryNumber(IncrementDecrement.Increment, EconnectConnectionString));
                glTransaccionHdr.BACHNUMB = nroLote;
                glTransaccionHdr.JRNENTRY = Jrnentry;
                glTransaccionHdr.REFRENCE = "CONS.TEL: " + nroDocAsociado;
                glTransaccionHdr.TRXDATE = DarFormatoFecha(cabeceraDoc.Fecdoc.Value);
                glTransaccionHdr.TRXTYPE = 0; // 0=Regular; 1=Reversing
                glTransaccionHdr.SERIES = 2; // 2=Financial;
                glTransaccionHdr.CURNCYID = idMoneda;
                //glTransaccionHdr.RATETPID = glTrx.RATETPID;
                //glTransaccionHdr.SQNCLINE
                //glTransaccionHdr.EXGTBDSC = glTrx.EXGTBDSC;
                //glTransaccionHdr.USERID = glTrx.USERID;
                glTransaccionHdr.SOURCDOC = ConfigurationManager.AppSettings.Get("SOURCDOC");

                //corregir el error del formato de fechas
                glTransaccionHdr.EXCHDATE = ConfigurationManager.AppSettings.Get("FechaCero");
                glTransaccionHdr.EXPNDATE = ConfigurationManager.AppSettings.Get("FechaCero");
                glTransaccionHdr.DATELMTS = 0;
                glTransaccionHdr.TRXDTDEF = 0;

                glTransaccionHdr.RVRSNGDT = ConfigurationManager.AppSettings.Get("FechaCero");
                // campo de debugu
                

                int i = 0;

                foreach (DetalleVentaBE det in listaDetalles)
                {
                    // crear distribucion contable
                    taGLTransactionLineInsert_ItemsTaGLTransactionLineInsert asientocuentaDebito = new taGLTransactionLineInsert_ItemsTaGLTransactionLineInsert();
                    asientocuentaDebito.ACTNUMST = ConfigurationManager.AppSettings.Get(det.Codestacion.ToUpper().Trim() + "_CUENTA_TELEPASS_DEB");
                    asientocuentaDebito.DEBITAMT = det.Total.Value;
                    asientocuentaDebito.CRDTAMNT = (Decimal)0.00;
                    asientocuentaDebito.JRNENTRY = Jrnentry;
                    asientocuentaDebito.BACHNUMB = nroLote;
                    asientocuentaDebito.DSCRIPTN = "PLACA: " + det.Placa + " TAG: " + det.NroTag;
                    //asientocuentaDebito.ORDOCNUM = det.Nrodocasociado;
                    asientocuentaDebito.SQNCLINE = (Decimal)(i + 1);
                    //buscar documento en gp para establecer como documento de referencia
                    asientocuentaDebito.CURNCYID = idMoneda;

                    nroArticulo = det.Codarticulo.Trim().PadLeft(2,'0');


                    //cuentaDebito.DOCNUMBR 
                    // agregar asiento a array de asientos
                    asientosContables[i] = asientocuentaDebito;
                    i++;

                    taGLTransactionLineInsert_ItemsTaGLTransactionLineInsert asientocuentaCredito = new taGLTransactionLineInsert_ItemsTaGLTransactionLineInsert();
                    asientocuentaCredito.ACTNUMST = ConfigurationManager.AppSettings.Get(det.Codestacion.ToUpper().Trim() + "_CUENTA_TELEPASS_CRED");
                    asientocuentaCredito.DEBITAMT = (Decimal)0.00;
                    asientocuentaCredito.CRDTAMNT = det.Total.Value;
                    asientocuentaCredito.JRNENTRY = Jrnentry;
                    asientocuentaCredito.BACHNUMB = nroLote;
                    asientocuentaCredito.DSCRIPTN = "PLACA: " + det.Placa + " TAG: " + det.NroTag;
                    asientocuentaCredito.SQNCLINE = (Decimal)(i + 1);
                    //buscar documento en gp para establecer como documento de referencia
                    asientocuentaCredito.CURNCYID = idMoneda;
                    //cuentaDebito.DOCNUMBR 
                    // agregar asiento a array de asientos
                    asientosContables[i] = asientocuentaCredito;
                    i++;
                }

                GLTransactionType glTransactionType = new GLTransactionType();
                glTransactionType.taGLTransactionHeaderInsert = glTransaccionHdr;
                glTransactionType.taGLTransactionLineInsert_Items = asientosContables;

                GLTransactionType[] myGLTransactionType = { glTransactionType };

                eConnectType eConnect = new eConnectType();

                eConnect.GLTransactionType = myGLTransactionType;

                XmlSerializer serializer = new XmlSerializer(eConnect.GetType());

                MemoryStream xmlMemoria = new MemoryStream();
                serializer.Serialize(xmlMemoria, eConnect);

                XmlDocument xmlDoc = new XmlDocument();
                xmlMemoria.Position = 0;
                xmlDoc.Load(xmlMemoria);
                xmlMemoria.Close();
                cadenaXML = xmlDoc.OuterXml;

            }
            catch (eConnectException ex)
            {
                //notificar de cualquier error de econnect
                Console.WriteLine("ERROR " + ex);
            }
            catch (Exception ex)
            {
                //notificar de cualquier error de econnect
                Console.WriteLine("ERROR " + ex);
            }
            return cadenaXML;

        }

        private static string DarFormatoFecha(DateTime _dateTime)
        {
            return _dateTime.ToString(EconnectDateFormat);
        }

        public static string SerializarSobrantes(CabeceraVentaBE cabeceraDoc, string nroLote)
        {
            string cadenaXML = "";
            String idMoneda = ConfigurationManager.AppSettings.Get("idMoneda");
            Int32 cantidadDecimalesMoneda = CompanyGPBE.ObtenerCantidadDecimalesPorMoneda(idMoneda);
            try
            {
                               
                List<DetalleVentaBE> listaDetalles = DetalleVentaBL.obtenerDetalleDocumentos(cabeceraDoc.TipDoc, cabeceraDoc.SerieDoc, cabeceraDoc.NroDoc);
                // crear un array para almacenar las lineas del documento
                taSopLineIvcInsert_ItemsTaSopLineIvcInsert[] detallesGP = new taSopLineIvcInsert_ItemsTaSopLineIvcInsert[listaDetalles.Count];
                int i = 0;
                decimal total = 0;
                foreach (DetalleVentaBE det in listaDetalles)
                {
                    taSopLineIvcInsert_ItemsTaSopLineIvcInsert lineaVenta = new taSopLineIvcInsert_ItemsTaSopLineIvcInsert();
                    string codArticulo = ConfigurationManager.AppSettings.Get("articuloSobrantes");
                    lineaVenta.CUSTNMBR = det.Idcliente;
                    lineaVenta.SOPTYPE = 3;
                    //lineaVenta.DOCID = ConfigurationManager.AppSettings.Get("idTipDocSobrantes")+det.Seriedoc;
                    lineaVenta.DOCID = tipoDocumentoVenta;
                    lineaVenta.ITEMNMBR = codArticulo;
                    lineaVenta.UOFM = ConfigurationManager.AppSettings.Get("unidad");
                    lineaVenta.CURNCYID = idMoneda;
                    // obtener cantidad de decimales de GP

                    lineaVenta.QUANTITY = Math.Round((Decimal)1, 0, MidpointRounding.AwayFromZero);
                    lineaVenta.UNITPRCE = det.Total.Value;
                    lineaVenta.XTNDPRCE = Math.Round(det.Total.Value, cantidadDecimalesMoneda, MidpointRounding.AwayFromZero);
                    // el sitio va a ser por cada estacion
                    // tendra la siguiente nomenclatura
                    //lineaVenta.LOCNCODE = ConfigurationManager.AppSettings.Get("sitio");  
                    lineaVenta.LOCNCODE = det.Codestacion.Trim().ToUpper();
                    lineaVenta.DOCDATE = DarFormatoFecha(det.Fecdoc.Value);
                    // verificar si tiene detraccion 
                    // crear cabecera de documento
                    // nivel de precio
                    lineaVenta.PRCLEVEL = "PEA." + det.Codestacion.Trim().ToUpper();
                    detallesGP[i] = lineaVenta;
                    i++;
                    total += det.Total.Value;

                }
                taSopHdrIvcInsert salesHdr = new taSopHdrIvcInsert();

               // GetSopNumber mySopNumber = new GetSopNumber();
                //salesHdr.SOPNUMBE = mySopNumber.GetNextSopNumber(3, ConfigurationManager.AppSettings.Get("idTipDocSobrantes"), EconnectConnectionString);
                //CREAR NUMERO CORRELATIVO DE DOCUMENTO
                //salesHdr.SOPNUMBE
                // guardar ese numero correlativo en una variable para asignarlo luego
                GetNextDocNumbers nextNumber = new GetNextDocNumbers();

               // salesHdr.SOPNUMBE = cabeceraDoc.NroDoc;
                salesHdr.SOPNUMBE = nextNumber.GetNextSOPNumber(IncrementDecrement.Increment, tipoDocumentoVenta, SopType.SOPInvoice, EconnectConnectionString);
                SopNum = salesHdr.SOPNUMBE;
                nroDocVenta = cabeceraDoc.NroDoc;
                salesHdr.CREATEDIST = 1;

                salesHdr.SOPTYPE = 3;
                salesHdr.DOCID = tipoDocumentoVenta;
                salesHdr.BACHNUMB = nroLote; // numero de lote
                salesHdr.LOCNCODE = cabeceraDoc.CodEstacion.Trim().ToUpper(); ;
                salesHdr.DOCDATE = DarFormatoFecha(cabeceraDoc.Fecdoc.Value);
                salesHdr.CUSTNMBR = cabeceraDoc.IdCliente;
                if (cabeceraDoc.NomCliente != null && cabeceraDoc.NomCliente.Trim() != String.Empty)
                {
                    salesHdr.CUSTNAME = cabeceraDoc.NomCliente;
                }
                salesHdr.CURNCYID = idMoneda;
                //salesHdr.CREATETAXES = 1;
                salesHdr.SUBTOTAL = total;
                salesHdr.DOCAMNT = total;
                salesHdr.USINGHEADERLEVELTAXES = 0;
                //salesHdr.CREATEDIST = 1; // 
                //AGREGAR MONTO COBRADO
                salesHdr.PYMTRCVD = total;
                
               

                var myNextNumber = new GetNextDocNumbers();
                //agregar pagos
                var pagos = new taCreateSopPaymentInsertRecord_ItemsTaCreateSopPaymentInsertRecord[1];
                taCreateSopPaymentInsertRecord_ItemsTaCreateSopPaymentInsertRecord pago = new taCreateSopPaymentInsertRecord_ItemsTaCreateSopPaymentInsertRecord();

                pago.SOPTYPE = 3;
                pago.SOPNUMBE = salesHdr.SOPNUMBE;
                pago.CUSTNMBR = salesHdr.CUSTNMBR;
                pago.DOCNUMBR = myNextNumber.GetNextRMNumber(IncrementDecrement.Increment, RMPaymentType.RMPayments, EconnectConnectionString);
                pago.DOCDATE = salesHdr.DOCDATE;
                pago.PYMTTYPE = 4;
                pago.DOCAMNT = salesHdr.DOCAMNT;
                // crear idChequera
                //ASIGNAR VARIABLE NRO PAGO
                nroPago = pago.DOCNUMBR;
                pago.CHEKBKID = cabeceraDoc.CodEstacion.Trim().ToUpper() + "_EF"; ;

                // agregar el pago al array de pagos
                pagos[0] = pago;

                // crear la transaccion de orden de venta
                SOPTransactionType OrdenVenta = new SOPTransactionType();

                // poblar la orden de venta
                // Populate the schema object with the SOP header and SOP line item objects
                OrdenVenta.taSopLineIvcInsert_Items = detallesGP;
                OrdenVenta.taSopHdrIvcInsert = salesHdr;
                OrdenVenta.taCreateSopPaymentInsertRecord_Items = pagos;

                // Create an array that holds SOPTransactionType objects
                // Populate the array with the SOPTransactionType schema object
                SOPTransactionType[] MySopTransactionType = { OrdenVenta };

                // Create an eConnect XML document object and populate it 
                // with the SOPTransactionType schema object
                eConnectType eConnect = new eConnectType();
                eConnect.SOPTransactionType = MySopTransactionType;
                XmlSerializer serializer = new XmlSerializer(eConnect.GetType());

                MemoryStream xmlMemoria = new MemoryStream();
                serializer.Serialize(xmlMemoria, eConnect);

                XmlDocument xmlDoc = new XmlDocument();
                xmlMemoria.Position = 0;
                xmlDoc.Load(xmlMemoria);
                xmlMemoria.Close();
                cadenaXML = xmlDoc.OuterXml;
                
            }
            catch (eConnectException ex)
            {
                //notificar de cualquier error de econnect
                Console.WriteLine("ERROR " + ex);
            }
            catch (Exception ex)
            {
                //notificar de cualquier error de econnect
                Console.WriteLine("ERROR " + ex);
            }

            return cadenaXML;
        }

        public static string SerializarDiscrepancias(CabeceraVentaBE cabeceraDoc, string nroLote)
        {
            string cadenaXML = "";
            String idMoneda = ConfigurationManager.AppSettings.Get("idMoneda");
            Int32 cantidadDecimalesMoneda = CompanyGPBE.ObtenerCantidadDecimalesPorMoneda(idMoneda);
            try
            {
                List<DetalleVentaBE> listaDetalles = DetalleVentaBL.obtenerDetalleDocumentos(cabeceraDoc.TipDoc, cabeceraDoc.SerieDoc, cabeceraDoc.NroDoc);
                // crear un array para almacenar las lineas del documento
                taSopLineIvcInsert_ItemsTaSopLineIvcInsert[] detallesGP = new taSopLineIvcInsert_ItemsTaSopLineIvcInsert[listaDetalles.Count];
                int i = 0;
                decimal total = 0;
                foreach (DetalleVentaBE det in listaDetalles)
                {
                    taSopLineIvcInsert_ItemsTaSopLineIvcInsert lineaVenta = new taSopLineIvcInsert_ItemsTaSopLineIvcInsert();
                    string codArticulo = det.Codestacion.Trim().ToUpper() + "." + ConfigurationManager.AppSettings.Get("articuloDiscrepancias");
                    lineaVenta.CUSTNMBR = det.Idcliente;
                    lineaVenta.SOPTYPE = 3;

                    lineaVenta.DOCID = tipoDocumentoVenta;
                    lineaVenta.ITEMNMBR = codArticulo;
                    lineaVenta.UOFM = ConfigurationManager.AppSettings.Get("unidad");
                    lineaVenta.CURNCYID = idMoneda;
                    // obtener cantidad de decimales de GP

                    lineaVenta.QUANTITY = Math.Round((Decimal)1, 0, MidpointRounding.AwayFromZero);
                    lineaVenta.UNITPRCE = det.Total.Value;
                    lineaVenta.XTNDPRCE = Math.Round(det.Total.Value, cantidadDecimalesMoneda, MidpointRounding.AwayFromZero);
                    // el sitio va a ser por cada estacion
                    // tendra la siguiente nomenclatura
                    //lineaVenta.LOCNCODE = ConfigurationManager.AppSettings.Get("sitio");  
                    lineaVenta.LOCNCODE = det.Codestacion.Trim().ToUpper();
                    lineaVenta.DOCDATE = DarFormatoFecha(det.Fecdoc.Value);
                    // verificar si tiene detraccion 

                    // crear cabecera de documento

                    // nivel de precio
                    lineaVenta.PRCLEVEL = "PEA." + det.Codestacion.Trim().ToUpper();
                    detallesGP[i] = lineaVenta;
                    i++;
                    total += det.Total.Value;

                }
                taSopHdrIvcInsert salesHdr = new taSopHdrIvcInsert();

               // GetSopNumber mySopNumber = new GetSopNumber();
              //  salesHdr.SOPNUMBE = mySopNumber.GetNextSopNumber(3, ConfigurationManager.AppSettings.Get("idTipDocDiscrepancias"), EconnectConnectionString);
                
                // guardar ese numero correlativo en una variable para utilizarlo luego
                GetNextDocNumbers nextNumber = new GetNextDocNumbers();
                salesHdr.SOPNUMBE = nextNumber.GetNextSOPNumber(IncrementDecrement.Increment, tipoDocumentoVenta, SopType.SOPInvoice, EconnectConnectionString);
                //salesHdr.SOPNUMBE = cabeceraDoc.NroDoc;

                nroDocVenta = cabeceraDoc.NroDoc;
                SopNum = salesHdr.SOPNUMBE;
                salesHdr.CREATEDIST = 1;

                salesHdr.SOPTYPE = 3;
                //salesHdr.DOCID = ConfigurationManager.AppSettings.Get("idTipDocDiscrepancias")+cabeceraDoc.SerieDoc;
                salesHdr.DOCID = tipoDocumentoVenta;
                salesHdr.BACHNUMB = nroLote; // numero de lote
                salesHdr.LOCNCODE = cabeceraDoc.CodEstacion.Trim().ToUpper(); ;
                salesHdr.DOCDATE = DarFormatoFecha(cabeceraDoc.Fecdoc.Value);
                salesHdr.CUSTNMBR = cabeceraDoc.IdCliente;
                if (cabeceraDoc.NomCliente != null && cabeceraDoc.NomCliente.Trim() != String.Empty)
                {
                    salesHdr.CUSTNAME = cabeceraDoc.NomCliente;
                }
                salesHdr.CURNCYID = idMoneda;
                //salesHdr.CREATETAXES = 1;
                salesHdr.SUBTOTAL = total;
                salesHdr.DOCAMNT = total;
                salesHdr.USINGHEADERLEVELTAXES = 0;
                //salesHdr.CREATEDIST = 1; // 
                //AGREGAR MONTO COBRADO
                salesHdr.PYMTRCVD = total;

               
                var myNextNumber = new GetNextDocNumbers();
                //agregar pagos
                var pagos = new taCreateSopPaymentInsertRecord_ItemsTaCreateSopPaymentInsertRecord[1];
                taCreateSopPaymentInsertRecord_ItemsTaCreateSopPaymentInsertRecord pago = new taCreateSopPaymentInsertRecord_ItemsTaCreateSopPaymentInsertRecord();

                pago.SOPTYPE = 3;
                pago.SOPNUMBE = salesHdr.SOPNUMBE;
                pago.CUSTNMBR = salesHdr.CUSTNMBR;
                pago.DOCNUMBR = myNextNumber.GetNextRMNumber(IncrementDecrement.Increment, RMPaymentType.RMPayments, EconnectConnectionString);
                pago.DOCDATE = salesHdr.DOCDATE;
                pago.PYMTTYPE = 4;
                pago.DOCAMNT = salesHdr.DOCAMNT;
                // crear idChequera
                //ASIGNAR VARIABLE NRO PAGO
                nroPago = pago.DOCNUMBR;
                pago.CHEKBKID = cabeceraDoc.CodEstacion.Trim().ToUpper() + "_EF"; ;

                // agregar el pago al array de pagos
                pagos[0] = pago;

                // crear la transaccion de orden de venta
                SOPTransactionType OrdenVenta = new SOPTransactionType();

                // poblar la orden de venta
                // Populate the schema object with the SOP header and SOP line item objects
                OrdenVenta.taSopLineIvcInsert_Items = detallesGP;
                OrdenVenta.taSopHdrIvcInsert = salesHdr;
                OrdenVenta.taCreateSopPaymentInsertRecord_Items = pagos;

                // Create an array that holds SOPTransactionType objects
                // Populate the array with the SOPTransactionType schema object
                SOPTransactionType[] MySopTransactionType = { OrdenVenta };

                // Create an eConnect XML document object and populate it 
                // with the SOPTransactionType schema object
                eConnectType eConnect = new eConnectType();
                eConnect.SOPTransactionType = MySopTransactionType;
                XmlSerializer serializer = new XmlSerializer(eConnect.GetType());

                MemoryStream xmlMemoria = new MemoryStream();
                serializer.Serialize(xmlMemoria, eConnect);

                XmlDocument xmlDoc = new XmlDocument();
                xmlMemoria.Position = 0;
                xmlDoc.Load(xmlMemoria);
                xmlMemoria.Close();
                cadenaXML = xmlDoc.OuterXml;

            }
            catch (eConnectException ex)
            {
                //notificar de cualquier error de econnect
                Console.WriteLine("ERROR " + ex);
            }
            catch (Exception ex)
            {
                //notificar de cualquier error de econnect
                Console.WriteLine("ERROR " + ex);
            }

            return cadenaXML;
        }

    }
}
