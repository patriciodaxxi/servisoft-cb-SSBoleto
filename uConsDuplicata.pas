unit uConsDuplicata;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  uConsPadrao, Data.DB, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, Vcl.Grids, Vcl.DBGrids, SMDBGrid, Vcl.ComCtrls,
  Vcl.DBCtrls, Vcl.StdCtrls, SMultiBtn, Vcl.ExtCtrls, Vcl.Mask, JvExMask,
  JvToolEdit, JvExComCtrls, JvDateTimePicker, JvMaskEdit, JvCheckedMaskEdit,
  JvDatePickerEdit, JvExExtCtrls, JvRadioGroup, JvExControls, JvDBLookup,
  uDMCadDuplicata, JvExStdCtrls, JvCombobox, Vcl.OleCtrls, BoletoX_TLB,
  uConfigTecnoSpeed, Vcl.Menus;

type
  TEnumTitulos = (tpNaoEnviados, tpEnviados, tpTodos);

  TEnumTipoImpressao = (tpNormal = 0, tpCarneDuplo = 1, tpCarneTriplo = 2, tpDuploRetrato = 3, tpMarcaDagua = 4, tpPersonalizado = 99);

  TImprimir = (opVisualizar, opImprimir);

type
  TfrmConsDuplicata = class(TfrmConsPadrao)
    edtConsulta: TEdit;
    lblDiversos: TLabel;
    DateInicial: TJvDateEdit;
    DateFinal: TJvDateEdit;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    comboBanco: TJvDBLookupCombo;
    Label6: TLabel;
    comboOcorrencia: TJvDBLookupCombo;
    ComboTitulo: TJvComboBox;
    Label7: TLabel;
    btnOpcoes: TSMButton;
    spdBoletoX1: TspdBoletoX;
    ts_Mensagem: TTabSheet;
    mmResposta: TMemo;
    mmEnvio: TMemo;
    popOpcoes: TPopupMenu;
    btnEnviar: TMenuItem;
    btnConsulta: TMenuItem;
    btnImpressao: TMenuItem;
    dlgSalvarPDF: TSaveDialog;
    Shape1: TShape;
    Label2: TLabel;
    Shape2: TShape;
    Label8: TLabel;
    Shape3: TShape;
    Label9: TLabel;
    rdgImpressao: TJvRadioGroup;
    GerarRemessa1: TMenuItem;
    function ConverteErroClasse(aErroClasse: TErroClasse): string;
    procedure FormShow(Sender: TObject);
    procedure btnConsultarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure comboOcorrenciaKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure comboBancoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SMDBGrid1GetCellParams(Sender: TObject; Field: TField; AFont: TFont; var Background: TColor; Highlight: Boolean);
    procedure btnEnviarClick(Sender: TObject);
    procedure btnConsultaClick(Sender: TObject);
    procedure btnImpressaoClick(Sender: TObject);
    procedure SMDBGrid1TitleClick(Column: TColumn);
    procedure GerarRemessa1Click(Sender: TObject);
  private
    { Private declarations }
    CampoConsulta: string;
    fDMCadDuplicata: TDMCadDuplicata;
    function fnc_Montar_IdIntegracao: string;
    procedure prc_Consulta_Duplicata;
    function CarregaConfig(Filial: Integer; Tipo: Integer): Boolean;
    procedure DoOnBoletoException(ASender: TObject; const aExceptionMessage: WideString);
    function fnc_Verificar: Boolean;
    function fnc_Montar_Envio: TStringList;
  public
    FBoletoX: TspdBoletoX;
    { Public declarations }
  end;

var
  frmConsDuplicata: TfrmConsDuplicata;

implementation

uses
  uUtilPadrao;

{$R *.dfm}

procedure TfrmConsDuplicata.btnConsultaClick(Sender: TObject);
var
  _ConsultarList: IspdRetConsultarLista;
  _ConsultarItem: IspdRetConsultarTituloItem;
  i, j, k, l: Integer;
begin
  inherited;
  if fDMCadDuplicata.qryConsulta_DuplicataID_INTEGRACAO.AsString = EmptyStr then
  begin
    Application.MessageBox('T�tulo ainda n�o enviado!', 'ATEN��O', MB_OK + MB_ICONWARNING);
    Exit;
  end;
  if not (CarregaConfig(comboFilial.KeyValue, 1)) then
    Application.MessageBox('Configura��es inv�lidas!', 'ATEN��O', MB_OK + MB_ICONWARNING);
  mmResposta.Lines.Clear;
  mmResposta.Refresh;
  mmResposta.Lines.BeginUpdate;

  try
    _ConsultarList := FBoletoX.Consultar(fDMCadDuplicata.qryConsulta_DuplicataID_INTEGRACAO.AsString);

    mmResposta.Lines.Add('.:: Consultar T�tulo ::.');
    mmResposta.Lines.Add('Mensagem: ' + _ConsultarList.Mensagem);
    mmResposta.Lines.Add('Status: ' + _ConsultarList.Status);

    if _ConsultarList.ErroConexao <> '' then
      mmResposta.Lines.Add('Erro Conex�o: ' + _ConsultarList.ErroConexao);

    mmResposta.Lines.Add('');

    while _ConsultarList.Count <> 0 do
    begin
      for i := 0 to pred(_ConsultarList.Count) do    //o conte�do de pred � equivalente a (_ConsultarList.Count - 1)
      begin
        _ConsultarItem := _ConsultarList.Item[i];
        mmResposta.Lines.Add('ITEM: ' + IntToStr(i + 1));
        mmResposta.Lines.Add('  IdIntegracao: ' + _ConsultarItem.IdIntegracao);
        mmResposta.Lines.Add('  Situacao: ' + _ConsultarItem.Situacao);
        mmResposta.Lines.Add('  Motivo: ' + _ConsultarItem.Motivo);
        mmResposta.Lines.Add('');
        mmResposta.Lines.Add('CEDENTE:');
        mmResposta.Lines.Add('  Agencia: ' + _ConsultarItem.CedenteAgencia);
        mmResposta.Lines.Add('  AgenciaDV: ' + _ConsultarItem.CedenteAgenciaDV);
        mmResposta.Lines.Add('  C�digo Banco: ' + _ConsultarItem.CedenteCodigoBanco);
        mmResposta.Lines.Add('  Carteira: ' + _ConsultarItem.CedenteCarteira);
        mmResposta.Lines.Add('  Conta: ' + _ConsultarItem.CedenteConta);
        mmResposta.Lines.Add('  DV da conta: ' + _ConsultarItem.CedenteContaNumeroDV);
        mmResposta.Lines.Add('  Numero Conv�nio: ' + _ConsultarItem.CedenteNumeroConvenio);
        mmResposta.Lines.Add('');
        mmResposta.Lines.Add('SACADO:');
        mmResposta.Lines.Add('  CPFCNPJ: ' + _ConsultarItem.SacadoCPFCNPJ);
        mmResposta.Lines.Add('  Nome: ' + _ConsultarItem.SacadoNome);
        mmResposta.Lines.Add('  Telefone: ' + _ConsultarItem.SacadoTelefone);
        mmResposta.Lines.Add('  Celular: ' + _ConsultarItem.SacadoCelular);
        mmResposta.Lines.Add('  Email: ' + _ConsultarItem.SacadoEmail);
        mmResposta.Lines.Add('  Endere�o N�mero: ' + _ConsultarItem.SacadoEnderecoNumero);
        mmResposta.Lines.Add('  Endere�o Bairro: ' + _ConsultarItem.SacadoEnderecoBairro);
        mmResposta.Lines.Add('  Endere�o CEP: ' + _ConsultarItem.SacadoEnderecoCEP);
        mmResposta.Lines.Add('  Endere�o Cidade: ' + _ConsultarItem.SacadoEnderecoCidade);
        mmResposta.Lines.Add('  Endere�o Complemento: ' + _ConsultarItem.SacadoEnderecoComplemento);
        mmResposta.Lines.Add('  Endere�o Logradouro: ' + _ConsultarItem.SacadoEnderecoLogradouro);
        mmResposta.Lines.Add('  Endere�o Pa�s: ' + _ConsultarItem.SacadoEnderecoPais);
        mmResposta.Lines.Add('  Endere�o UF: ' + _ConsultarItem.SacadoEnderecoUF);
        mmResposta.Lines.Add('  Sacador Avalista: ' + _ConsultarItem.TituloSacadorAvalista);
        mmResposta.Lines.Add('  Sacador Avalista Inscricao: ' + _ConsultarItem.TituloInscricaoSacadorAvalista);
        mmResposta.Lines.Add('  Endere�o Sacador Avalista: ' + _ConsultarItem.TituloSacadorAvalistaEndereco);
        mmResposta.Lines.Add('  Cidade Sacador Avalista: ' + _ConsultarItem.TituloSacadorAvalistaCidade);
        mmResposta.Lines.Add('  CEP Sacador Avalista: ' + _ConsultarItem.TituloSacadorAvalistaCEP);
        mmResposta.Lines.Add('  UF Sacador Avalista: ' + _ConsultarItem.TituloSacadorAvalistaUF);
        mmResposta.Lines.Add('');
        mmResposta.Lines.Add('T�TULO:');
        mmResposta.Lines.Add('  Nosso N�mero: ' + _ConsultarItem.TituloNossoNumero);
        mmResposta.Lines.Add('  N�mero Documento: ' + _ConsultarItem.TituloNumeroDocumento);
        mmResposta.Lines.Add('  Nosso N�mero Impress�o: ' + _ConsultarItem.TituloNossoNumeroImpressao);
        mmResposta.Lines.Add('  Origem Documento: ' + _ConsultarItem.TituloOrigemDocumento);
        mmResposta.Lines.Add('  Linha Digit�vel: ' + _ConsultarItem.TituloLinhaDigitavel);
        mmResposta.Lines.Add('  C�digo de Barras: ' + _ConsultarItem.TituloCodigoBarras);
        mmResposta.Lines.Add('  C�digo Emiss�o Bloqueto: ' + _ConsultarItem.TituloCodEmissaoBloqueto);
        mmResposta.Lines.Add('  Titulo Aceite: ' + _ConsultarItem.TituloAceite);
        mmResposta.Lines.Add('  Avalista: ' + _ConsultarItem.TituloInscricaoSacadorAvalista);
        mmResposta.Lines.Add('  Doc Esp�cie: ' + _ConsultarItem.TituloDocEspecie);
        mmResposta.Lines.Add('  Postagem: ' + _ConsultarItem.TituloPostagemBoleto);

        mmResposta.Lines.Add('  C�digo para baixa ou devolu��o: ' + _ConsultarItem.TituloCodBaixaDevolucao);
        mmResposta.Lines.Add('  Prazo para baixa ou devolu��o: ' + _ConsultarItem.TituloPrazoBaixa);
        mmResposta.Lines.Add('  Data Emiss�o: ' + _ConsultarItem.TituloDataEmissao);
        mmResposta.Lines.Add('  For�ar Fator Vencimento: ' + BoolToStr(_ConsultarItem.TituloForcarFatorVencimento, True));
        mmResposta.Lines.Add('  Data Vencimento: ' + _ConsultarItem.TituloDataVencimento);
        mmResposta.Lines.Add('  C�digo de Desconto: ' + _ConsultarItem.TituloCodDesconto);
        mmResposta.Lines.Add('  Data Desconto: ' + _ConsultarItem.TituloDataDesconto);
        mmResposta.Lines.Add('  Valor Desconto: ' + FloatToStr(_ConsultarItem.TituloValorDescontoTaxa));
        mmResposta.Lines.Add('  C�digo de Desconto2: ' + _ConsultarItem.TituloCodDesconto2);
        mmResposta.Lines.Add('  Outras Deducoes: ' + _ConsultarItem.TituloOutrasDeducoes);
        mmResposta.Lines.Add('  Data Desconto: ' + _ConsultarItem.TituloDataDesconto2);
        mmResposta.Lines.Add('  Valor Desconto: ' + FloatToStr(_ConsultarItem.TituloValorDescontoTaxa2));
        mmResposta.Lines.Add('  C�digo de Juros: ' + _ConsultarItem.TituloCodigoJuros);
        mmResposta.Lines.Add('  Data Juros: ' + _ConsultarItem.TituloDataJuros);
        mmResposta.Lines.Add('  Valor Juros: ' + FloatToStr(_ConsultarItem.TituloValorJuros));
        mmResposta.Lines.Add('  Prazo Protesto: ' + _ConsultarItem.TituloPrazoProtesto);
        mmResposta.Lines.Add('  Instrucoes: ' + _ConsultarItem.TituloInstrucoes);
        mmResposta.Lines.Add('  Mensagem 1: ' + _ConsultarItem.TituloMensagem01);
        mmResposta.Lines.Add('  Mensagem 2: ' + _ConsultarItem.TituloMensagem02);
        mmResposta.Lines.Add('  Mensagem 3: ' + _ConsultarItem.TituloMensagem03);
        mmResposta.Lines.Add('  T�tuloInstrucao 1: ' + _ConsultarItem.TituloInstrucao1);
        mmResposta.Lines.Add('  T�tuloInstrucao 2: ' + _ConsultarItem.TituloInstrucao2);
        mmResposta.Lines.Add('  Informacoes Adicionais: ' + _ConsultarItem.TituloInformacoesAdicionais);
        mmResposta.Lines.Add('  Local Pagamento: ' + _ConsultarItem.TituloLocalPagamento);
        mmResposta.Lines.Add('  Parcela: ' + _ConsultarItem.TituloParcela);
        mmResposta.Lines.Add('  Variacao Carteira: ' + _ConsultarItem.TituloVariacaoCarteira);
        mmResposta.Lines.Add('  Categoria: ' + _ConsultarItem.TituloCategoria);
        mmResposta.Lines.Add('  Modalidade: ' + _ConsultarItem.TituloModalidade);
        mmResposta.Lines.Add('  Cip: ' + _ConsultarItem.TituloCip);
        mmResposta.Lines.Add('  Ios "utilizado apenas pelo Santander": ' + _ConsultarItem.TituloIos);
        mmResposta.Lines.Add('  Cod Cliente "exclusivo para os bancos HSBC e Safra": ' + _ConsultarItem.TituloCodCliente);
        mmResposta.Lines.Add('  Valor: ' + FloatToStr(_ConsultarItem.TituloValor));
        mmResposta.Lines.Add('  Pagamento Minimo: ' + FloatToStr(_ConsultarItem.TituloPagamentoMinimo));
        mmResposta.Lines.Add('  Data Cr�dito: ' + _ConsultarItem.PagamentoDataCredito);
        mmResposta.Lines.Add('  Valor Cobrado: ' + FloatToStr(_ConsultarItem.TituloValorCobrado));
        mmResposta.Lines.Add('  T�tulo Pago: ' + BoolToStr(_ConsultarItem.PagamentoRealizado));
        mmResposta.Lines.Add('  Valor Cr�dito: ' + FloatToStr(_ConsultarItem.PagamentoValorCredito));
        mmResposta.Lines.Add('  Valor Outros Acr�scimos: ' + FloatToStr(_ConsultarItem.TituloValorOutrosAcrescimos));
        mmResposta.Lines.Add('  Valor Pago: ' + FloatToStr(_ConsultarItem.PagamentoValorPago));
        mmResposta.Lines.Add('  Valor Taxa Cobran�a: ' + FloatToStr(_ConsultarItem.PagamentoValorTaxaCobranca));
        mmResposta.Lines.Add('  Valor Abatimento: ' + FloatToStr(_ConsultarItem.TituloValorAbatimento));
        mmResposta.Lines.Add('  Valor Outras Despesas: ' + FloatToStr(_ConsultarItem.PagamentoValorOutrasDespesas));
        mmResposta.Lines.Add('  Valor IOF: ' + FloatToStr(_ConsultarItem.PagamentoValorIOF));
        mmResposta.Lines.Add('  C�digo Multa: ' + _ConsultarItem.TituloCodigoMulta);
        mmResposta.Lines.Add('  Valor Multa: ' + FloatToStr(_ConsultarItem.TituloValorMulta));
        mmResposta.Lines.Add('  Valor Multa Taxa: ' + FloatToStr(_ConsultarItem.TituloValorMultaTaxa));
        mmResposta.Lines.Add('  Data Multa: ' + _ConsultarItem.PagamentoData);
        mmResposta.Lines.Add('  Data Pagamento: ' + _ConsultarItem.PagamentoData);
        mmResposta.Lines.Add('  Valor Outros Cr�ditos: ' + FloatToStr(_ConsultarItem.PagamentoValorOutrosCreditos));
        mmResposta.Lines.Add('  Pagamento Valor Desconto: ' + FloatToStr(_ConsultarItem.PagamentoValorDesconto));
        mmResposta.Lines.Add('  Pagamento Valor Acr�scimos: ' + FloatToStr(_ConsultarItem.PagamentoValorAcrescimos));
        mmResposta.Lines.Add('  Pagamento Valor Abatimento: ' + FloatToStr(_ConsultarItem.PagamentoValorAbatimento));
        mmResposta.Lines.Add('  Impress�o Visualizada: ' + BoolToStr(_ConsultarItem.ImpressaoVisualizada, True));   //Converte o retorno para "False" ou "True"
        mmResposta.Lines.Add('  Impress�o Visualizada Data: ' + (_ConsultarItem.TituloDataImpressaoVisualizada));
        mmResposta.Lines.Add('');

        { ---> M�todo removido, sendo substitu�do pelo _ConsultarItem.CountTituloMovimentos
               que est� exemplificado logo abaixo do trecho comentado.
        if _ConsultarItem.TituloOcorrencias <> nil then
        begin
          mmoResposta.Lines.Add('  LISTA DE OCORR�NCIAS:');
          for j := 0 to _ConsultarItem.TituloOcorrencias.Count - 1 do
          begin
            mmoResposta.Lines.Add('    C�digo: ' + IntToStr(j+1) + ': ' + _ConsultarItem.TituloOcorrencias.Item[j].Codigo);
            mmoResposta.Lines.Add('    Mensagem: ' + IntToStr(j+1) + ': ' + _ConsultarItem.TituloOcorrencias.Item[j].Mensagem);
          end;
          mmoResposta.Lines.Add('------------');
        end;
        }


        for k := 0 to _ConsultarItem.CountTituloMovimentos - 1 do
        begin
          mmResposta.Lines.Add('  MOVIMENTOS:');
          mmResposta.Lines.Add('  Movimento C�digo: ' + _ConsultarItem.TituloMovimentos[k].Codigo);
          mmResposta.Lines.Add('  Movimento Mensagem: ' + _ConsultarItem.TituloMovimentos[k].Mensagem);
          mmResposta.Lines.Add('  Movimento Data: ' + _ConsultarItem.TituloMovimentos[k].Data);
          mmResposta.Lines.Add('  Movimento Taxa: ' + FloatToStr(_ConsultarItem.TituloMovimentos[k].Taxa));
          for l := 0 to _ConsultarItem.TituloMovimentos[k].CountOcorrencias - 1 do
          begin
            mmResposta.Lines.Add('  OCORR�NCIAS:');
            mmResposta.Lines.Add('     Ocorr�ncias C�digo: ' + _ConsultarItem.TituloMovimentos[k].Ocorrencias[l].Codigo);
            mmResposta.Lines.Add('     Ocorr�ncias Mensagem: ' + _ConsultarItem.TituloMovimentos[k].Ocorrencias[l].Mensagem);
          end;
          mmResposta.Lines.Add('');
        end;

      end;

      _ConsultarList.PaginaSeguinte;           //Utilize este par�metro quando a consulta for feita com mais de 1000 idIntegracao por vez. O While far� a consulta de 20 em 20 idIntegracao, e o "PaginaSeguinte" repete a consulta enquanto houverem p�ginas a serem consultadas.

    end;

  finally
    mmResposta.Lines.EndUpdate;
    pg_Principal.ActivePage := ts_Mensagem;
  end;

end;

procedure TfrmConsDuplicata.btnConsultarClick(Sender: TObject);
begin
  inherited;
  if comboFilial.KeyValue = 0 then
  begin
    MessageDlg('Informe a Filial', mtInformation, [mbYes], 0);
    comboFilial.SetFocus;
    Exit;
  end;
  if comboOcorrencia.KeyValue = 0 then
  begin
    MessageDlg('Informe a Ocorr�ncia', mtInformation, [mbYes], 0);
    comboOcorrencia.SetFocus;
    Exit;
  end;
  mmResposta.Lines.Clear;
  mmEnvio.Lines.Clear;
  prc_Consulta_Duplicata;
end;

procedure TfrmConsDuplicata.btnEnviarClick(Sender: TObject);
var
  _BoletoList: IspdRetIncluirLista;
  i: Integer;
  listaIdsIntegracao: string;
  vLista: TStringList;
begin
  inherited;
  if not fnc_Verificar then
    Exit;
  if not (CarregaConfig(comboFilial.KeyValue, 1)) then
    Application.MessageBox('Configura��es inv�lidas!', 'ATEN��O', MB_OK + MB_ICONWARNING);

  vLista := TStringList.Create();
  mmResposta.Lines.Clear;
  mmResposta.Refresh;
  mmResposta.Lines.BeginUpdate;
  fDMCadDuplicata.qryConsulta_Duplicata.First;
  while not fDMCadDuplicata.qryConsulta_Duplicata.Eof do
  begin
    if (gridConsulta.SelectedRows.CurrentRowSelected) then
    begin
      vLista.Clear;
      vLista := fnc_Montar_Envio;
      for i := 0 to vLista.Count - 1 do
      begin
        mmEnvio.Lines.Add(vLista[i]);
      end;
    end;
    fDMCadDuplicata.qryConsulta_Duplicata.Next;
  end;

  try
    _BoletoList := FBoletoX.Incluir(mmEnvio.Lines.Text);

    mmResposta.Lines.Clear;
    mmResposta.Lines.Add('.:: Incluir Boleto ::.');
    mmResposta.Lines.Add('Mensgem: ' + _BoletoList.Mensagem);
    mmResposta.Lines.Add('Status: ' + _BoletoList.Status);
    mmResposta.Lines.Add('');

    for i := 0 to _BoletoList.Count - 1 do
    begin
      mmResposta.Lines.Add('Item: ' + IntToStr(i + 1));
      mmResposta.Lines.Add('  NumeroDocumento: ' + _BoletoList[i].NumeroDocumento);
      mmResposta.Lines.Add('  IdIntegracao: ' + _BoletoList[i].IdIntegracao);
      mmResposta.Lines.Add('  Situacao: ' + _BoletoList[i].Situacao);
      mmResposta.Lines.Add('  NossoNumero: ' + _BoletoList[i].NossoNumero);
      mmResposta.Lines.Add('  Banco: ' + _BoletoList[i].Banco);
      mmResposta.Lines.Add('  Conta: ' + _BoletoList[i].Conta);
      mmResposta.Lines.Add('  Convenio: ' + _BoletoList[i].Convenio);
      mmResposta.Lines.Add('  Erro: ' + _BoletoList[i].Erro);
      mmResposta.Lines.Add('  ErroClasse: ' + ConverteErroClasse(_BoletoList[i].ErroClasse));
      mmResposta.Lines.Add('');
      fDMCadDuplicata.prc_Abrir_Duplicata(StrToInt(_BoletoList[i].NumeroDocumento));
      fDMCadDuplicata.prc_Gravar_Duplicata(StrToInt(_BoletoList[i].NumeroDocumento), _BoletoList[i].IdIntegracao);

      if i = 0 then                                       //este if identifica se foi feito o envio de 1 boleto por tx2 ou de um lote de boletos, para alimentar os campos que recebem os idIntegracao
        listaIdsIntegracao := _BoletoList[i].IdIntegracao
      else
        listaIdsIntegracao := _BoletoList[i].IdIntegracao + ',' + listaIdsIntegracao;

    end;

    mmResposta.SelStart := 1;
    mmResposta.SelLength := 1;

  finally
    mmResposta.Lines.EndUpdate;
    pg_Principal.ActivePage := ts_Mensagem;
      //mmoTX2.Lines.Clear;
  end;

end;

procedure TfrmConsDuplicata.btnImpressaoClick(Sender: TObject);
var
  TipoImpressao: TEnumTipoImpressao;
  _ImprimirLoteList: IspdRetImprimirLote;
  _Impressao: IspdRetConsultarLoteImpressao;
  _SalvarPDFLote: IspdRetSalvarLoteImpressaoPDF;
  ProtocoloImpressao: string;
  ListaID: string;
  numeroConsultas: Integer;
begin
  inherited;
  if fDMCadDuplicata.qryConsulta_DuplicataID_INTEGRACAO.AsString = EmptyStr then
  begin
    Application.MessageBox('T�tulo ainda n�o enviado!', 'ATEN��O', MB_OK + MB_ICONWARNING);
    Exit;
  end;

  pg_Principal.ActivePage := ts_Mensagem;
  TipoImpressao := tpNormal;
  if not (CarregaConfig(comboFilial.KeyValue, 1)) then
    Application.MessageBox('Configura��es inv�lidas!', 'ATEN��O', MB_OK + MB_ICONWARNING);
  mmResposta.Lines.Clear;
  mmResposta.Refresh;
  mmResposta.Lines.BeginUpdate;

  ListaID := fnc_Montar_IdIntegracao;

  _ImprimirLoteList := FBoletoX.ImprimirLote(ListaID, IntToStr(integer(TipoImpressao)));
  Sleep(2000);
  if _ImprimirLoteList.Protocolo <> EmptyStr then
    ProtocoloImpressao := _ImprimirLoteList.Protocolo;
  mmResposta.Lines.Clear;
  mmResposta.Lines.Add('.:: IMPRESS�O BOLETO::.');
  mmResposta.Lines.Add('Mensagem: ' + _ImprimirLoteList.Mensagem);
  mmResposta.Lines.Add('Status: ' + _ImprimirLoteList.Status);
  mmResposta.Lines.Add('Protocolo: ' + _ImprimirLoteList.Protocolo);
  if AnsiSameText(_ImprimirLoteList.Status, 'ERRO') then
  begin
    mmResposta.Lines.Add('ErroClasse: ' + ConverteErroClasse(_ImprimirLoteList.ErroClasse));
  end;
  mmResposta.Lines.Add('');
  mmResposta.Lines.EndUpdate;
  mmResposta.Lines.Add('.:: CONSULTAR PROTOCOLO IMPRESS�O ::');
  mmResposta.Lines.EndUpdate;

  case TImprimir(rdgImpressao.ItemIndex) of
    opVisualizar:
      begin
        dlgSalvarPDF.FileName := _ImprimirLoteList.Protocolo + dlgSalvarPDF.Filter;
        if dlgSalvarPDF.Execute then
        begin
          try
            repeat           // Repete at� que a nossa API tenha terminado de tratar o pedido de impress�o
              begin
                _SalvarPDFLote := FBoletoX.SalvarLoteImpressaoPDF(_ImprimirLoteList.Protocolo, dlgSalvarPDF.FileName);

                mmResposta.Lines.Add('.:: CONSULTAR PROTOCOLO LOTE IMPRESS�O - Tentativa ' + IntToStr(numeroConsultas) + ' ::.');
                mmResposta.Lines.Add('Situacao: ' + _SalvarPDFLote.Situacao);    //'PROCESSANDO': impress�o em processamento  // 'PROCESSADA': impress�o processada com sucesso  //  'FALHA': erro ao gerar a impress�o. (O erro estar� preenchido na propriedade Mensagem)  //  'CANCELADA': impress�o abortada
                mmResposta.Lines.Add('Mensagem: ' + _SalvarPDFLote.Mensagem);
                mmResposta.Lines.Add('Status: ' + _SalvarPDFLote.Status);

                if _SalvarPDFLote.ErroConexao <> '' then
                  mmResposta.Lines.Add('Erro Conex�o: ' + _SalvarPDFLote.ErroConexao);

                if AnsiSameText(_SalvarPDFLote.Status, 'ERRO') then
                  mmResposta.Lines.Add('ErroClasse: ' + ConverteErroClasse(_SalvarPDFLote.ErroClasse));

                if _SalvarPDFLote.Situacao = 'PROCESSANDO' then
                  Sleep(2000);    //'Se o processamento da API ainda n�o terminou, guarda 2 segundos.

                numeroConsultas := numeroConsultas + 1;
                mmResposta.Lines.Add('');
              end;

            until ((_SalvarPDFLote.Situacao = 'PROCESSADA') and (numeroConsultas < 40)) or (numeroConsultas > 40);

          finally
            mmResposta.Lines.EndUpdate;
          end;
        end;
      end;

    opImprimir:
      begin
        _Impressao := FBoletoX.ConsultarLoteImpressao(ProtocoloImpressao, GetDefaultPrinterName);
        while _Impressao.Situacao = 'PROCESSANDO' do
        begin
          mmResposta.Lines.Add('.:: PROCESSANDO ::');
          mmResposta.Lines.EndUpdate;
          _Impressao := FBoletoX.ConsultarLoteImpressao(ProtocoloImpressao, GetDefaultPrinterName);
        end;
        mmResposta.Lines.Add('.:: CONSULTAR PROTOCOLO IMPRESS�O ::');
        mmResposta.Lines.Add('Situacao: ' + _Impressao.Situacao);    //'PROCESSANDO': impress�o em processamento  // 'PROCESSADA': impress�o processada com sucesso  //  'FALHA': erro ao gerar a impress�o. (O erro estar� preenchido na propriedade Mensagem)  //  'CANCELADA': impress�o abortada
        mmResposta.Lines.Add('Mensagem: ' + _Impressao.Mensagem);
        mmResposta.Lines.Add('Status: ' + _Impressao.Status);
        if _Impressao.ErroConexao <> '' then
          mmResposta.Lines.Add('Erro Conex�o: ' + _Impressao.ErroConexao);
        if AnsiSameText(_Impressao.Status, 'ERRO') then
          mmResposta.Lines.Add('ErroClasse: ' + ConverteErroClasse(_Impressao.ErroClasse));
        if _Impressao.Status = 'SUCESSO' then
        begin

        end;
        mmResposta.Lines.Add('');
        mmResposta.Lines.EndUpdate;
      end;
  end;
end;

function TfrmConsDuplicata.CarregaConfig(Filial, Tipo: Integer): Boolean;
var
  vConfigTecnoSpeed: TConfigTecnoSpeed;
begin
  Result := True;
  vConfigTecnoSpeed := TConfigTecnoSpeed.Create(Filial, Tipo);
  try
    FBoletoX.Config.URL := vConfigTecnoSpeed.URL;
    FBoletoX.ConfigurarSoftwareHouse(vConfigTecnoSpeed.CNPJSH, vConfigTecnoSpeed.Token);
    FBoletoX.Config.CedenteCpfCnpj := vConfigTecnoSpeed.CNPJCedente;
    FBoletoX.OnException := DoOnBoletoException;
    FBoletoX.Config.SalvarLogs := true;  //Salva os logs na pasta em que se encontra o exe do projeto
  except
    Result := False;
  end;
end;

procedure TfrmConsDuplicata.comboBancoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  inherited;
  if (Key = VK_ESCAPE) then
    comboBanco.KeyValue := '0';
end;

procedure TfrmConsDuplicata.comboOcorrenciaKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  inherited;
  if (Key = VK_ESCAPE) then
    comboOcorrencia.KeyValue := '0';
end;

function TfrmConsDuplicata.ConverteErroClasse(aErroClasse: TErroClasse): string;
begin
  case aErroClasse of
    ecValidacao:
      Result := 'VALIDACAO';
    ecAutenticacao:
      Result := 'AUTENTICACAO';
    ecNaoEncontrado:
      Result := 'NAOENCONTRADO';
    ecInterno:
      Result := 'INTERNO';
    ecParametroTamanhoExcedido:
      Result := 'PARAMETROTAMANHOEXCEDIDO';
    ecServidorIndisponivel:
      Result := 'SERVIDORINDISPONIVEL';
    ecNaoTratado:
      Result := 'NAOTRATADO';
    ecAcessoNegado:
      Result := 'ACESSONEGADO';
    ecNenhum:
      Result := 'NENHUM';
  end;
end;

procedure TfrmConsDuplicata.DoOnBoletoException(ASender: TObject; const aExceptionMessage: WideString);
begin
  MessageBox(0, PChar(aExceptionMessage), 'Exce��o do BoletoX', MB_ICONERROR or MB_OK);
end;

function TfrmConsDuplicata.fnc_Montar_Envio: TStringList;
var
  vInstrucao1: string;
  vInstrucao2: string;
begin
  vInstrucao1 := '';
  vInstrucao2 := '';
  Result := TStringList.Create;
  Result.Add('INCLUIRBOLETO');
  with fDMCadDuplicata do
  begin
    // Inicio Cedente
    qryConsulta.Close;
    qryConsulta.SQL.Clear;
    qryConsulta.SQL.Add('select C.NUMCONTA, C.DIG_CONTA, B.CODIGO CODIGO_BANCO, ');
    qryConsulta.SQL.Add('C.COD_CEDENTE CONVENIO_NUMERO, ESP.CODIGO ESPECIE, ');
    qryConsulta.SQL.Add('INS1.NOME INSTRUCAO1, INS2.NOME INSTRUCAO2 ');
    qryConsulta.SQL.Add('from CONTAS C ');
    qryConsulta.SQL.Add('inner join BANCO B on B.ID = C.ID_BANCO ');
    qryConsulta.SQL.Add('left join COB_TIPO_CADASTRO ESP on C.ID_ESPECIE = ESP.ID ');
    qryConsulta.SQL.Add('left join COB_TIPO_CADASTRO INS1 on C.ID_INSTRUCAO1 = INS1.ID ');
    qryConsulta.SQL.Add('left join COB_TIPO_CADASTRO INS2 on C.ID_INSTRUCAO2 = INS2.ID ');
    qryConsulta.SQL.Add('where C.ID = :ID');
    qryConsulta.ParamByName('ID').AsInteger := qryConsulta_DuplicataID_CONTA_BOLETO.AsInteger;
    qryConsulta.Open();
    if not (qryConsulta.IsEmpty) then
    begin
      Result.Add('CedenteContaNumero=' + qryConsulta.FieldByName('NUMCONTA').Value);
      Result.Add('CedenteContaNumeroDV=' + qryConsulta.FieldByName('DIG_CONTA').Value);
      Result.Add('CedenteConvenioNumero=' + qryConsulta.FieldByName('CONVENIO_NUMERO').Value);
      Result.Add('CedenteContaCodigoBanco=' + qryConsulta.FieldByName('CODIGO_BANCO').Value);
      Result.Add('TituloDocEspecie=' + qryConsulta.FieldByName('ESPECIE').Value);
      vInstrucao1 := qryConsulta.FieldByName('INSTRUCAO1').AsString;
      vInstrucao2 := qryConsulta.FieldByName('INSTRUCAO2').AsString;
    end;
    // Fim Cedente
    // Inicio Sacado
    qryConsulta.Close;
    qryConsulta.SQL.Clear;
    qryConsulta.SQL.Add('select P.EMAIL_PGTO, P.NOME NOME_SACADO, P.CNPJ_CPF, P.CEP, P.DDDCELULAR, P.CELULAR, P.NUM_END, ');
    qryConsulta.SQL.Add('P.BAIRRO, P.CIDADE, P.ENDERECO, PA.NOME NOME_PAIS, P.UF, P.DDDFONE1, P.TELEFONE1 FROM PESSOA P ');
    qryConsulta.SQL.Add('left join PAIS PA on P.ID_PAIS = PA.ID ');
    qryConsulta.SQL.Add('where ID = :ID');
    qryConsulta.ParamByName('ID').AsInteger := qryConsulta_DuplicataID_PESSOA.AsInteger;
    qryConsulta.Open();
    if not (qryConsulta.IsEmpty) then
    begin
      Result.Add('SacadoEmail=' + qryConsulta.FieldByName('EMAIL_PGTO').Value);
      Result.Add('SacadoNome=' + qryConsulta.FieldByName('NOME_SACADO').Value);
      Result.Add('SacadoCPFCNPJ=' + qryConsulta.FieldByName('CNPJ_CPF').Value);
      Result.Add('SacadoEnderecoCEP=' + qryConsulta.FieldByName('CEP').Value);
      Result.Add('SacadoEnderecoNumero=' + qryConsulta.FieldByName('NUM_END').Value);
      Result.Add('SacadoEnderecoBairro=' + qryConsulta.FieldByName('BAIRRO').Value);
      Result.Add('SacadoEnderecoCidade=' + qryConsulta.FieldByName('CIDADE').Value);
      Result.Add('SacadoEnderecoLogradouro=' + qryConsulta.FieldByName('ENDERECO').Value);
      Result.Add('SacadoEnderecoPais=' + qryConsulta.FieldByName('NOME_PAIS').Value);
      Result.Add('SacadoEnderecoUF=' + qryConsulta.FieldByName('UF').Value);
      Result.Add('SacadoTelefone=' + qryConsulta.FieldByName('TELEFONE1').Value);
    end;
    //Fim Sacado
    // Inicio T�tulo
    Result.Add('TituloNossoNumero=' + IntToStr(qryConsulta_DuplicataID.AsInteger));
    Result.Add('TituloNumeroDocumento=' + IntToStr(qryConsulta_DuplicataID.AsInteger));
    Result.Add('TituloDataVencimento=' + DateToStr(qryConsulta_DuplicataDTVENCIMENTO.AsDateTime));
    Result.Add('TituloDataEmissao=' + DateToStr(qryConsulta_DuplicataDTEMISSAO.AsDateTime));
    Result.Add('TituloValor=' + FormatFloat('0.00', qryConsulta_DuplicataVLR_PARCELA.AsFloat));
    Result.Add('TituloMensagem01=' + SQLLocate('CONTAS', 'ID', 'MENSAGEM_FIXA', qryConsulta_DuplicataID_CONTA.AsString));
    Result.Add('TituloMensagem02=' + '');
    Result.Add('TituloMensagem03=' + '');
    Result.Add('TituloInformacoesAdicionais=' + '');
    Result.Add('TituloInstrucoes=' + vInstrucao1);
    Result.Add('TituloInstrucoes=' + vInstrucao2);
    // Fim T�tulo
  end;
  Result.Add('SALVARBOLETO');

end;

function TfrmConsDuplicata.fnc_Verificar: Boolean;
var
  vMensagem: string;
begin
  Result := True;
  vMensagem := '';
  if comboBanco.KeyValue = 0 then
    vMensagem := vMensagem + #13 + 'Banco n�o informado!';
  if comboFilial.KeyValue = 0 then
    vMensagem := vMensagem + #13 + 'Filial n�o informada!';
  if vMensagem = '' then
  begin
    fDMCadDuplicata.qryContas.Locate('ID', comboBanco.KeyValue, [loCaseInsensitive]);
    if (comboFilial.KeyValue > 0) and (fDMCadDuplicata.qryContasFILIAL.AsInteger <> comboFilial.KeyValue) then
      vMensagem := vMensagem + #13 + 'Banco selecionado n�o pertence a filial!';
  end;
  if vMensagem <> '' then
  begin
    Result := False;
    MessageDlg(vMensagem, mtWarning, [mbOK], 0);
  end;
end;

procedure TfrmConsDuplicata.FormCreate(Sender: TObject);
begin
  inherited;
  FBoletoX := TspdBoletoX.Create(nil);
  fDMCadDuplicata := TDMCadDuplicata.Create(Self);
  dsConsulta.DataSet := fDMCadDuplicata.qryConsulta_Duplicata;
end;

procedure TfrmConsDuplicata.FormShow(Sender: TObject);
begin
  inherited;
  fDMCadDuplicata.qryContas.Close;
  fDMCadDuplicata.qryContas.Open();
  if qryFilial.RecordCount = 1 then
    comboFilial.KeyValue := qryFilialID.AsInteger;

  if fDMCadDuplicata.qryContas.RecordCount = 1 then
  begin
    comboBanco.KeyValue := fDMCadDuplicata.qryContasID.AsInteger;
    fDMCadDuplicata.qryContasBeforeScroll(fDMCadDuplicata.qryContas);
    comboOcorrencia.KeyValue := fDMCadDuplicata.qryOcorrenciaID.AsInteger;
  end;
end;

procedure TfrmConsDuplicata.GerarRemessa1Click(Sender: TObject);
var
  _RemessaList: IspdRetGerarRemessaLista;
  _RemessaItem: IspdRetGerarRemessaItem;
  i, j: Integer;
  conteudoRemessa: TStringList;
  ListaID : String;
begin
  inherited;
  if fDMCadDuplicata.qryConsulta_DuplicataID_INTEGRACAO.AsString = EmptyStr then
  begin
    Application.MessageBox('T�tulo ainda n�o enviado!', 'ATEN��O', MB_OK + MB_ICONWARNING);
    Exit;
  end;

  pg_Principal.ActivePage := ts_Mensagem;
  if not (CarregaConfig(comboFilial.KeyValue, 1)) then
    Application.MessageBox('Configura��es inv�lidas!', 'ATEN��O', MB_OK + MB_ICONWARNING);
  mmResposta.Lines.Clear;
  mmResposta.Refresh;
  mmResposta.Lines.BeginUpdate;

  ListaID := fnc_Montar_IdIntegracao;

  try
    _RemessaList := FBoletoX.GerarRemessa(ListaID);

    mmResposta.Lines.Clear;
    mmResposta.Lines.Add('.:: GERAR REMESSA ::.');
    mmResposta.Lines.Add('Mensagem: ' + _RemessaList.Mensagem);
    mmResposta.Lines.Add('Status: ' + _RemessaList.Status);
    mmResposta.Lines.Add('');

    for i := 0 to _RemessaList.Count - 1 do
    begin
      _RemessaItem := _RemessaList.Item[i];
      mmResposta.Lines.Add('ITEM: ' + IntToStr(i+1));
      mmResposta.Lines.Add('  Mensagem: ' + _RemessaItem.Mensagem);
      mmResposta.Lines.Add('  Remessa: ' + _RemessaItem.Remessa);
      mmResposta.Lines.Add('  Banco: ' + _RemessaItem.Banco);
      mmResposta.Lines.Add('  Conta: ' + _RemessaItem.Conta);
      mmResposta.Lines.Add('  N�mero Atual da Remessa: ' + IntToStr(_RemessaItem.NumeroAtualRemessa));
      mmResposta.Lines.Add('  Transmiss�o autom�tica?: ' + BoolToStr(_RemessaItem.TransmissaoAutomatica));
      mmResposta.Lines.Add('  Erro: ' + _RemessaItem.Erro);

      conteudoRemessa := TStringList.Create;                           // ---
      conteudoRemessa.Text := UTF8Encode(_RemessaItem.Remessa);               //    |--> Salva o conte�do da remessa em um arquivo texto
      conteudoRemessa.SaveToFile('C:\Temp\conteudoRemessaUTF8.txt');   // ---

      for j := 0 to _RemessaItem.Titulos.Count-1 do
      begin
        mmResposta.Lines.Add('  IdIntegracao ' + IntToStr(j+1) + ': ' + _RemessaItem.Titulos.Item[j]);
      end;

      mmResposta.Lines.Add('');

      conteudoRemessa.Free;

    end;

  finally
    mmResposta.Lines.EndUpdate;

  end;

end;

procedure TfrmConsDuplicata.prc_Consulta_Duplicata;
begin
  fDMCadDuplicata.qryConsulta_Duplicata.SQL.Text := fDMCadDuplicata.ctCommandDup;
  fDMCadDuplicata.qryConsulta_Duplicata.Close;
  fDMCadDuplicata.qryConsulta_Duplicata.SQL.Add(' WHERE DUP.TIPO_ES = ' + QuotedStr('E') + ' AND DUP.VLR_RESTANTE > 0');
  if comboFilial.KeyValue > 0 then
    fDMCadDuplicata.qryConsulta_Duplicata.SQL.Add(' AND DUP.FILIAL = ' + IntToStr(comboFilial.KeyValue));
  if edtConsulta.Text <> '' then
    fDMCadDuplicata.qryConsulta_Duplicata.SQL.Add(' AND (DUP. ' + CampoConsulta + ' = ' + QuotedStr(edtConsulta.Text) + ') ');
  if DateInicial.Date > 10 then
    fDMCadDuplicata.qryConsulta_Duplicata.SQL.Add(' AND DUP.DTEMISSAO >= ' + QuotedStr(FormatDateTime('MM/DD/YYYY', DateInicial.Date)));
  if DateFinal.Date > 10 then
    fDMCadDuplicata.qryConsulta_Duplicata.SQL.Add(' AND DUP.DTEMISSAO <= ' + QuotedStr(FormatDateTime('MM/DD/YYYY', DateFinal.Date)));
  if SQLLocate('PARAMETROS_FIN', 'ID', 'TIPO_GERACAO_REM', '1') = '1' then
    fDMCadDuplicata.qryConsulta_Duplicata.SQL.Add(' AND (DUP.ID_CONTA_BOLETO = ' + IntToStr(comboBanco.KeyValue) + ') ')
  else
    fDMCadDuplicata.qryConsulta_Duplicata.SQL.Add(' AND (DUP.ID_CONTA_BOLETO = ' + IntToStr(comboBanco.KeyValue) + ' OR DUP.ID_CONTA_BOLETO IS NULL) ');
  case TEnumTitulos(ComboTitulo.ItemIndex) of
    tpNaoEnviados:
      fDMCadDuplicata.qryConsulta_Duplicata.SQL.Add(' AND ((DUP.NUM_REMESSA = 0) OR (DUP.NUM_REMESSA IS NULL))');
    tpEnviados:
      fDMCadDuplicata.qryConsulta_Duplicata.SQL.Add(' AND (DUP.NUM_REMESSA > 0)');
  end;
  if comboOcorrencia.KeyValue > 0 then
    fDMCadDuplicata.qryConsulta_Duplicata.ParamByName('ID_OCORRENCIA').AsInteger := comboOcorrencia.KeyValue;

  fDMCadDuplicata.qryConsulta_Duplicata.Open();

end;

function TfrmConsDuplicata.fnc_Montar_IdIntegracao: string;
var
  Lista: TStringList;
  I: Integer;
begin
  Lista := TStringList.Create;
  try
    fDMCadDuplicata.qryConsulta_Duplicata.First;
    fDMCadDuplicata.qryConsulta_Duplicata.DisableControls;
    while not fDMCadDuplicata.qryConsulta_Duplicata.eof do
    begin
      if gridConsulta.SelectedRows.CurrentRowSelected then
      begin
        Lista.Add(fDMCadDuplicata.qryConsulta_DuplicataID_INTEGRACAO.AsString + ',');
      end;
      fDMCadDuplicata.qryConsulta_Duplicata.Next;
    end;
    Lista[Lista.Count - 1] := StringReplace(Lista[Lista.Count - 1], ',', '', [rfReplaceAll]);
    for I := 0 to Lista.Count - 1 do
      Result := Result + Lista[I];
  finally
    FreeAndNil(Lista);
    fDMCadDuplicata.qryConsulta_Duplicata.EnableControls;
  end;
end;

procedure TfrmConsDuplicata.SMDBGrid1GetCellParams(Sender: TObject; Field: TField; AFont: TFont; var Background: TColor; Highlight: Boolean);
begin
  inherited;
  if fDMCadDuplicata.qryConsulta_Duplicata.IsEmpty then
    Exit;
  if (fDMCadDuplicata.qryConsulta_DuplicataID_INTEGRACAO.AsString <> EmptyStr) then
  begin
    Background := clGreen;
    AFont.Color := clWhite;
  end;
  if (fDMCadDuplicata.qryConsulta_DuplicataID_IMPRESSAO.AsString <> EmptyStr) then
  begin
    Background := clOlive;
    AFont.Color := clWhite;
  end;
  if (fDMCadDuplicata.qryConsulta_DuplicataDTVENCIMENTO.AsDateTime < Date) then
  begin
    Background := clRed;
    AFont.Color := clWhite;
  end;

end;

procedure TfrmConsDuplicata.SMDBGrid1TitleClick(Column: TColumn);
begin
  inherited;
  lblDiversos.Caption := Column.Field.DisplayLabel + ':';
  CampoConsulta := Column.FieldName;
end;

end.

