unit ufrm_search_double;

{
    Commandoo Program: Helper application for Linux commands / CLI
    Copyright (C) 2017 Julius Heinrich Ludwig Schön / Ronald Michael Spicer
    created by Julius Schön / R. Spicer
    Foto.TimePirate.org / TimePirate.org / PaganToday.TimePirate.org
    Julius@TimePirate.org

        This program is free software: you can redistribute it and/or modify
        it under the terms of the GNU General Public License as published by
        the Free Software Foundation, version 3 of the License.

        This program is distributed in the hope that it will be useful,
        but WITHOUT ANY WARRANTY; without even the implied warranty of
        MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
        GNU General Public License for more details.

        You should have received a copy of the GNU General Public License
        along with this program.  If not, see <http://www.gnu.org/licenses/>.

}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls
  , lcltype {THis is needed for key up keyboard constants}
  , unitSearch
  , ufrmBoolExpr, Menus, Spin
  ;

type

  { Tfrm_Search_double }

  Tfrm_Search_double = class( TForm)
    spnRealValue : TFloatSpinEdit;
    lblFreeTextReal : TLabel;
    lblValueInt : TLabel;
    lblSeType : TLabel;
    rgSeList : TRadioGroup;
    procedure FormCreate( Sender : TObject );
    procedure FormHide( Sender : TObject );
    procedure FormKeyDown( Sender : TObject; var Key : Word; Shift : TShiftState );
    procedure rgSeListSelectionChanged( Sender : TObject );
    procedure spnIntValueChange( Sender : TObject );
  private
    { private declarations }
    fSe_SI : TSearchItem;
    fBE : TfrmBoolExpr;
    fIsLoading : boolean;

    procedure EnableControls( Idx : integer );
    procedure RegisterBoolExpr( BE : TfrmBoolExpr );
    procedure SetSe_SI( AValue : TSearchItem );
    procedure UpdateSearchValue;
  public
    { public declarations }
    procedure Link_SI_BoolExpr( anSI : TSearchItem; BE : TfrmBoolExpr );
    property Se_SI : TSearchItem read fSe_SI write SetSe_SI;

  end;

var
  frm_Search_double : Tfrm_Search_double;

implementation

uses ufrmSearch
    , ufrmMsgDlg
    , unitDBStructure
    , unitDBConstants
    , unitGlob
    , unitglobform
    ;

{$R *.lfm}

{ Tfrm_Search_double }

procedure Tfrm_Search_double.rgSeListSelectionChanged( Sender : TObject );
begin

  EnableControls( rgSeList.ItemIndex );

  if not assigned( fBE ) or fIsLoading or ( rgSeList.Itemindex < 0 ) then
    exit;

  Se_SI.Condition := ReturnSearchCondition( rgSeList.ItemIndex, cConditionsAllowed_Number );

  TfrmSearch( Parent ).UpdateCaption( fBE );

end;


procedure Tfrm_Search_double.FormCreate( Sender : TObject );
begin

  font.size := cDefaultFontSize;
  FormAutoAdjustLayout( self );
  ApplyChangeFont( Self );
  fIsLoading := false;
  rgSeList.Caption := crg_MatchType;
  lblValueInt.Caption := crg_Value;

  GetAllowedSearchConditions( rgSeList.Items, cConditionsAllowed_Number );

end;

procedure Tfrm_Search_double.FormHide( Sender : TObject );
begin
  rgSeList.ItemIndex := -1;
end;

procedure Tfrm_Search_double.FormKeyDown( Sender : TObject; var Key : Word; Shift : TShiftState );
begin
  //pressing return in memo sent the key to parent form which clicked the OK button. ugh.
    if key = vk_return then
      Key := VK_UNKNOWN;
end;

procedure Tfrm_Search_double.UpdateSearchValue;
begin
//callers of this maybe need to check fIsLoading, but not always
  Se_SI.SearchValue := Floattostr( spnRealValue.Value );
  TfrmSearch( Parent ).UpdateCaption( fBE );
end;

procedure Tfrm_Search_double.spnIntValueChange( Sender : TObject );
begin
  if fIsLoading then
    exit;
  UpdateSearchValue;
end;

procedure Tfrm_Search_double.EnableControls( Idx : integer );
begin

  if Idx < 0 then
    exit;

  lblFreeTextReal.Caption := rgSeList.Items[ Idx ];

end;

procedure Tfrm_Search_double.RegisterBoolExpr( BE : TfrmBoolExpr );
begin
  fBE := BE;
end;

procedure Tfrm_Search_double.SetSe_SI( AValue : TSearchItem );
var
  LabelType : TSearchOperatorType;
begin

  if AValue.SIT <> sitDouble then
    raise EErrorDevelopment.Create( 'Tfrm_Search_Double.SetSe_SI: Float/Real Type expected.' );

  LabelType := AValue.SearchOperatorType;
  if LabelType <> sotNone then
    raise EErrorDevelopment.Create( 'Tfrm_Search_Double.SetSe_SI: Invalid Operator Type.' );

  fIsLoading := true;

  //No, don't do ==> if fSe_SI = AValue then Exit;

  fSe_SI := AValue;

  lblSEType.caption := format( cusSearchCaption_Double, [ fSe_SI.siDisplayCaption ] );

  rgSeList.ItemIndex := ReturnSearchConditionIdx( fSe_SI.Condition, cConditionsAllowed_Number );

  spnRealValue.Value := StrToFloat( SE_SI.SearchValue );

  fIsLoading := false;

  if not self.Showing then
    Show;

end;

procedure Tfrm_Search_double.Link_SI_BoolExpr( anSI : TSearchItem; BE : TfrmBoolExpr );
begin
  RegisterBoolExpr( BE );
  Se_SI := anSI;
  if anSI.InValidMsg <> '' then
  begin
    if assigned( gSearchInfo ) then
    begin
      gSearchInfo.Text :=  gSearchInfo.Text + anSI.InValidMsg + LineEnding + LineEnding;
    end
    else
    begin
      MsgDlgMessage( ccapusSearchDetailProblem, anSI.InValidMsg );
      MsgDlgInfo( TForm( Parent ) );
    end;
    anSI.ClearInvalidMessage;
  end;
end;

end.

