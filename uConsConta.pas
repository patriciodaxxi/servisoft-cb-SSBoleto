unit uConsConta;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uConsPadrao, Data.DB, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, Vcl.Grids, Vcl.DBGrids, SMDBGrid,
  Vcl.ComCtrls, Vcl.DBCtrls, Vcl.StdCtrls, SMultiBtn, Vcl.ExtCtrls, uConfigTecnoSpeed,
  Vcl.OleCtrls, BoletoX_TLB, uDMCadConta, JvExControls, JvDBLookup;

type
  TEnumEnvio = (tpConta, tpConvenio);

type
  TfrmConsConta = class(TfrmConsPadrao)
    btnEnviar: TSMButton;
    spdBoletoX1: TspdBoletoX;
    ts_Mensagem: TTabSheet;
    mmEnvio: TMemo;
    mmResposta: TMemo;
    rdgTipoEnvio: TRadioGroup;
    procedure FormCreate(Sender: TObject);
    procedure btnConsultarClick(Sender: TObject);
    procedure btnEnviarClick(Sender: TObject);
  private
    { Private declarations }
   procedure CarregaConfig(Filial, Tipo: Integer);
   function fnc_Montar_Envio : TStringList;
   procedure DoOnBoletoException(ASender: TObject; const aExceptionMessage: WideString);
   procedure prc_Enviar_Conta;
   procedure prc_Enviar_Convenio;
  public
    { Public declarations }
      FBoletoX: TspdBoletoX;
end;

var
  frmConsConta: TfrmConsConta;
  fDMCadConta : TdmCadConta;

implementation


{$R *.dfm}

procedure TfrmConsConta.btnConsultarClick(Sender: TObject);
begin
  inherited;
  fDMCadConta.qryConsulta.Close;
  if comboFilial.KeyValue > 0 then
    fDMCadConta.qryConsulta.ParamByName('ID').AsInteger := qryFilialID.AsInteger
  else
    fDMCadConta.qryConsulta.ParamByName('ID').AsInteger := 0;
  fDMCadConta.qryConsulta.Open;
end;

procedure TfrmConsConta.btnEnviarClick(Sender: TObject);
var
  _Conta: IspdRetCadastrarConta;
begin
  inherited;
  case TEnumEnvio(rdgTipoEnvio.ItemIndex) of
    tpConta : begin
      if fDMCadConta.qryConsultaID_CONTA_TECNOSPEED.AsInteger > 0 then
      begin
        MessageDlg('Conta j� cadastrada!',mtInformation,[mbOK],0);
        Exit;
      end;
      prc_Enviar_Conta;
    end;
    tpConvenio : begin
      if fDMCadConta.qryConsultaID_CONVENIO_TECNOSPEED.AsInteger > 0 then
      begin
       MessageDlg('Conv�nio j� cadastrado!',mtInformation,[mbOK],0);
       Exit;
      end;
      if fDMCadConta.qryConsultaID_CONTA_TECNOSPEED.AsInteger = 0 then
      begin
       MessageDlg('Conta n�o cadastrada!',mtInformation,[mbOK],0);
       Exit;
      end;

      prc_Enviar_Convenio;
    end;
  end;

end;

procedure TfrmConsConta.CarregaConfig(Filial, Tipo: Integer);
var
  vConfigTecnoSpeed : TConfigTecnoSpeed;
begin
  vConfigTecnoSpeed := TConfigTecnoSpeed.Create(Filial,Tipo);
  FBoletoX.Config.URL :=  vConfigTecnoSpeed.URL;
  FBoletoX.ConfigurarSoftwareHouse(vConfigTecnoSpeed.CNPJSH, vConfigTecnoSpeed.Token);
  FBoletoX.Config.CedenteCpfCnpj := vConfigTecnoSpeed.CNPJCedente;
  FBoletoX.OnException := DoOnBoletoException;
  FBoletoX.Config.SalvarLogs := true;  //Salva os logs na pasta em que se encontra o exe do projeto
end;

procedure TfrmConsConta.DoOnBoletoException(ASender: TObject;
  const aExceptionMessage: WideString);
begin
  MessageBox(0, PChar(aExceptionMessage), 'Exce��o do BoletoX', MB_ICONERROR or MB_OK);
end;

function TfrmConsConta.fnc_Montar_Envio: TStringList;
begin
  Result := TStringList.Create;
  case TEnumEnvio(rdgTipoEnvio.ItemIndex) of
    tpConta : begin
      Result.Add('INCLUIRCEDENTECONTA');
      Result.Add('ContaCodigoBanco='+ fDMCadConta.qryConsultaCODIGO.AsString);
      Result.Add('ContaAgencia=' + fDMCadConta.qryConsultaAGENCIA.AsString);
      Result.Add('ContaAgenciaDV=' + fDMCadConta.qryConsultaDIG_AGENCIA.AsString);
      Result.Add('ContaNumero=' + fDMCadConta.qryConsultaNUMCONTA.AsString);
      Result.Add('ContaNumeroDV=' + fDMCadConta.qryConsultaDIG_CONTA.AsString);
      Result.Add('ContaTipo=' + 'CORRENTE');
      Result.Add('ContaCodigoBeneficiario=' + fDMCadConta.qryConsultaCOD_CEDENTE.AsString);
      Result.Add('SALVARCEDENTECONTA');
    end;
    tpConvenio : begin
      Result.Add('INCLUIRCONTACONVENIO');
      Result.Add('ConvenioNumero='+ fDMCadConta.qryConsultaCOD_CEDENTE.AsString);
      Result.Add('ConvenioDescricao=' + fDMCadConta.qryConsultaNOME.AsString);
      Result.Add('ConvenioCarteira=' + fDMCadConta.qryConsultaCARTEIRA.AsString);
      Result.Add('ConvenioEspecie=' + 'R$');
      if fDMCadConta.qryConsultaACBR_LAYOUTREMESSA.AsString = 'C240' then
        Result.Add('ConvenioPadraoCNAB=' + '240' )
      else
        Result.Add('ConvenioPadraoCNAB=' + '400');
      Result.Add('ConvenioUtilizaVan=' + '0');
      Result.Add('Conta=' + fDMCadConta.qryConsultaID_CONTA_TECNOSPEED.AsString);
//      Result.Add('ConvenioNumeroRemessa=' );
//      if fDMCadConta.qryConsultaREINICIAR_NUM_REMESSA_DIA.AsString = 'S' then
//        Result.Add('ConvenioReiniciarDiariamente=' + 'true')
//      else
//        Result.Add('ConvenioReiniciarDiariamente=' + 'false');
      Result.Add('SALVARCONTACONVENIO');
    end;
  end;
end;

procedure TfrmConsConta.FormCreate(Sender: TObject);
begin
  inherited;
  FBoletoX := TspdBoletoX.Create(nil);
  fDMCadConta := TdmCadConta.Create(Self);
  dsConsulta.DataSet := fDMCadConta.qryConsulta;
end;

procedure TfrmConsConta.prc_Enviar_Conta;
var
  _Conta: IspdRetCadastrarConta;
begin
  CarregaConfig(fDMCadConta.qryConsultaID.AsInteger,1);

  mmEnvio.Lines.Clear;
  mmEnvio.Lines := fnc_Montar_Envio;

  mmResposta.Lines.Clear;
  mmResposta.Refresh;
  mmResposta.Lines.BeginUpdate;
  try
    _Conta := FBoletoX.CadastrarConta(mmEnvio.Lines.Text);

    mmResposta.Lines.Clear;
    mmResposta.Lines.Add('.:: Cadastrar Conta ::.');
    mmResposta.Lines.Add('Mensgem: '          + _Conta.Mensagem);
    mmResposta.Lines.Add('Status: '           + _Conta.Status);
    mmResposta.Lines.Add('Erro de conex�o: '  + _Conta.ErroConexao);
    mmResposta.Lines.Add('');

    if _Conta.Status = 'SUCESSO' then
    begin
      mmResposta.Lines.Add('  Id Conta: '            + _Conta.IdConta);
      mmResposta.Lines.Add('  C�digo Banco: '        + _Conta.CodigoBanco);
      mmResposta.Lines.Add('  Ag�ncia: '             + _Conta.Agencia);
      mmResposta.Lines.Add('  Ag�nciaDV: '           + _Conta.AgenciaDV);
      mmResposta.Lines.Add('  Conta: '               + _Conta.Conta);
      mmResposta.Lines.Add('  Conta DV: '            + _Conta.ContaDV);
      mmResposta.Lines.Add('  Tipo Conta: '          + _Conta.TipoConta);
      mmResposta.Lines.Add('  C�digo Benefic�rio: '  + _Conta.CodigoBeneficiario);
      mmResposta.Lines.Add('  C�digo Empresa: '      + _Conta.CodigoEmpresa);
      mmResposta.Lines.Add('');
      fDMCadConta.prc_Abrir_Conta(fDMCadConta.qryConsultaID.AsInteger);
      fDMCadConta.prc_Gravar_Conta(StrToInt(_Conta.IdConta));
    end;
    mmResposta.SelStart  := 1;
    mmResposta.SelLength := 1;
  finally
    mmResposta.Lines.EndUpdate;
    mmEnvio.Lines.Clear;
    pg_Principal.ActivePage := ts_Mensagem;
  end;

end;

procedure TfrmConsConta.prc_Enviar_Convenio;
var
 _Convenio: IspdRetCadastrarConvenio;
begin
  CarregaConfig(fDMCadConta.qryConsultaID.AsInteger,1);

  mmEnvio.Lines.Clear;
  mmEnvio.Lines := fnc_Montar_Envio;

  mmResposta.Lines.Clear;
  mmResposta.Refresh;
  mmResposta.Lines.BeginUpdate;
  try
    _Convenio := FBoletoX.CadastrarConvenio(mmEnvio.Lines.Text);

    mmResposta.Lines.Clear;
    mmResposta.Lines.Add('.:: Cadastrar Conv�nio ::.');
    mmResposta.Lines.Add('Mensgem: '         + _Convenio.Mensagem);
    mmResposta.Lines.Add('Status: '          + _Convenio.Status);
    mmResposta.Lines.Add('Erro de conex�o: ' + _Convenio.ErroConexao);
    mmResposta.Lines.Add('');

    if _Convenio.Status = 'SUCESSO' then
    begin
      mmResposta.Lines.Add('  Id Conv�nio: '               + _Convenio.IdConvenio);
      mmResposta.Lines.Add('  N�mero Conv�nio: '           + _Convenio.NumeroConvenio);
      mmResposta.Lines.Add('  Descri��o: '                 + _Convenio.DescricaoConvenio);
      mmResposta.Lines.Add('  Carteira: '                  + _Convenio.Carteira);
      mmResposta.Lines.Add('  Esp�cie: '                   + _Convenio.Especie);
      mmResposta.Lines.Add('  Padr�o CNAB: '               + _Convenio.PadraoCNAB);
      mmResposta.Lines.Add('  Utiliza VAN: '               + BoolToStr(_Convenio.UtilizaVan));
      mmResposta.Lines.Add('  N�mero Remessa: '            + _Convenio.NumeroRemessa);
      mmResposta.Lines.Add('  Reiniciar N�mero Remessa: '  + BoolToStr(_Convenio.ReiniciarDiariamente));
      mmResposta.Lines.Add('');
      fDMCadConta.prc_Abrir_Conta(fDMCadConta.qryConsultaID.AsInteger);
      fDMCadConta.prc_Gravar_Convenio(StrToInt(_Convenio.IdConvenio));
    end;

    mmResposta.SelStart  := 1;
    mmResposta.SelLength := 1;
  finally
    mmResposta.Lines.EndUpdate;
    mmEnvio.Lines.Clear;
    pg_Principal.ActivePage := ts_Mensagem;
  end;


end;

end.
