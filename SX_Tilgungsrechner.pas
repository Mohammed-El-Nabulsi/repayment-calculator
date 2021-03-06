unit SX_Tilgungsrechner;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, StdCtrls, ComCtrls, ExtCtrls, Math, jpeg;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    DarlehenEditBox: TEdit;
    ZinssatzEditBox: TEdit;
    JahrOderMonatComboBox: TComboBox;
    Darlehensbetrag: TLabel;
    Zinssatz: TLabel;
    TilgungsSatzEditBox: TEdit;
    Tilgung: TLabel;
    BerechnenButton: TButton;
    MonatComboBox: TComboBox;
    JahrLabel: TLabel;
    AnfangsJahrEditBox: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label9: TLabel;
    RateTextLabel: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label5: TLabel;
    DarlehensbetragLabel: TLabel;
    ZinssatzLabel: TLabel;
    TilgungLabel: TLabel;
    RateLabel: TLabel;
    SummeZinsenLabel: TLabel;
    DatumLabel: TLabel;
    GesamtlaufzeitLabel: TLabel;
    TabsTeil: TPageControl;
    TabSheet1: TTabSheet;
    Tabelle: TStringGrid;
    TabSheet2: TTabSheet;
    GraphFeld: TPaintBox;
    ErstesDatumLabel: TLabel;
    ZweitesDatumLabel: TLabel;
    DrittesDatumLabel: TLabel;
    LetztesDatumLabel: TLabel;
    ErstesDarlehenLabel: TLabel;
    ZweitesDarlehenLabel: TLabel;
    DrittesDarlehenLabel: TLabel;
    ViertesDarlehenLabel: TLabel;
    Label6: TLabel;
    Button1: TButton;
    Button2: TButton;
    Label10: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label7: TLabel;
    AnfangsdatumLabel: TLabel;
    Bevel1: TBevel;
    Label13: TLabel;
    Image1: TImage;
    Bevel2: TBevel;
    Bevel3: TBevel;
    procedure BerechnenButtonClick(Sender: TObject);
    procedure JahrOderMonatComboBoxChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BerechneTabelle(darlehen, zinsSatz, tilgungsSatz :double; anfangsmonat, anfangsjahr: integer);
    procedure DarlehenEditBoxChange(Sender: TObject);
    procedure ZinssatzEditBoxChange(Sender: TObject);
    procedure TilgungsSatzEditBoxChange(Sender: TObject);
    procedure MonatComboBoxChange(Sender: TObject);
    procedure AnfangsJahrEditBoxChange(Sender: TObject);
    procedure KannBerechnen();
    function WelcherMonat(index :integer): string;
    procedure TabsTeilChange(Sender: TObject);
    procedure ZeichneGraph();
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure TabelleZuruecksetzen();
    function GueltigeEingabe(eingabe :string; istGleitkommawert :boolean) : boolean;
    function LetzteEingabeLoeschen(s :string) : string;

  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Form1: TForm1;
  IsMonat :boolean;
  DarlehenVeraendert :boolean = false;
  ZinssatzVeraendert :boolean = false;
  TilgungVeraendert :boolean = false;
  RatenArtVeraendert :boolean = false;
  AnfangsmonatVeraendert :boolean = false;
  AnfangsJahrVeraendert :boolean = false;

  BerechnungAbgeschlossen :boolean = false;
  DarlehenDatenArray : Array of double;

implementation

{$R *.DFM}

procedure TForm1.FormCreate(Sender: TObject);
begin
     Tabelle.Cells [0,0] := 'Periode';
     Tabelle.Cells [1,0] := 'Rate, �';
     Tabelle.Cells [2,0] := 'Zinsanteil, �' ;
     Tabelle.Cells [3,0] := 'Tilgungsanteil, �';
     Tabelle.Cells [4,0] := 'Restschuld, �' ;
     TabsTeil.Pages[0].Name := 'Liste';
     TabsTeil.Pages[1].Name := 'Graph';
     TabsTeil.ActivePageIndex := 0;
end;

procedure TForm1.BerechnenButtonClick(Sender: TObject);
var darlehen, zinssatz, tilgungssatz: double;
    anfangsmonat, anfangsjahr, i :integer;
begin
   //Daten einlesen
   darlehen := StrToFloat(DarlehenEditBox.Text);
   zinssatz := StrToFloat(ZinssatzEditBox.Text);
   tilgungssatz := StrToFloat(TilgungssatzEditBox.Text);
   if(IsMonat = true) then
      anfangsmonat := MonatCombobox.ItemIndex + 1
   else Anfangsmonat := 0;
   anfangsjahr := StrToInt(AnfangsJahrEditBox.Text);
   BerechneTabelle(darlehen, zinssatz, tilgungssatz, anfangsmonat, anfangsjahr);
end;

procedure TForm1.BerechneTabelle(darlehen, zinsSatz, tilgungsSatz :double;
                                 anfangsmonat, anfangsjahr: integer);
var ratenSumme, startZinsAnteil, startTilgungsAnteil, differenz, zinsAnteil,
    tilgungsAnteil, rate, restschuld :double;
    periode :string;
    reihe, jahr, monat :integer;
    anzahlMonate, erstesDrittel, zweitesDrittel :integer;
begin
     TabelleZuruecksetzen();
     restschuld := darlehen;
     jahr := anfangsJahr;
     monat := anfangsmonat;
     rate := 0;
     ratenSumme := 0;
     SetLength(DarlehenDatenArray, 1);
     DarlehenDatenArray[0] := restschuld;
     reihe := 1;

     if(IsMonat = true) then
     begin
         startZinsAnteil := ((darlehen/100)*zinsSatz)/12;
         startTilgungsAnteil := ((darlehen/100)*tilgungsSatz)/12;
     end
     else
     begin
         startZinsAnteil := ((darlehen/100)*zinsSatz);
         startTilgungsAnteil := ((darlehen/100)*tilgungsSatz);
     end;

     while restschuld > 0 do
     begin
         //Rechnung
         if(IsMonat = true) then
             zinsAnteil := ((restschuld/100)*zinsSatz)/12
         else
             zinsAnteil := ((restschuld/100)*zinsSatz);

         differenz := startZinsAnteil - zinsAnteil;
         tilgungsAnteil := startTilgungsAnteil + differenz;
         rate := zinsAnteil + tilgungsAnteil;
         restschuld := restschuld - tilgungsAnteil;
         if(restschuld < 0) then restschuld := 0;
         ratenSumme := ratenSumme + rate;

         SetLength(DarlehenDatenArray,Length(DarlehenDatenArray) + 1);
         DarlehenDatenArray[High(DarlehenDatenArray)] :=  restschuld;

         //Z�hlen der Zeit
         if(IsMonat = true) then
         begin
             periode := WelcherMonat(monat) + ' ' + IntToStr(jahr);
             monat := monat + 1;
             if (monat = 13) then
             begin
                 jahr := jahr + 1;
                 monat := 1;
             end;
         end
         else
         begin
             periode := IntToStr(jahr);
             jahr := jahr + 1;
         end;

         //F�llen der Tabelle
         Tabelle.RowCount:=Tabelle.RowCount+1;
         Tabelle.Cells[0,reihe]:= Periode;
         Tabelle.Cells[1,reihe]:= FloatToStrf(rate, ffFixed,6,2);
         Tabelle.Cells[2,reihe]:= FloatToStrf(zinsAnteil, ffFixed,6,2);
         Tabelle.Cells[3,reihe]:= FloatToStrf(tilgungsAnteil, ffFixed,6,2);
         Tabelle.Cells[4,reihe]:= FloatToStrf(restschuld, ffFixed,6,2);
         reihe := reihe + 1;
     end;
     BerechnungAbgeschlossen := true;

     //F�llen der Zusammenfassung
     if(IsMonat = true) then
     begin
         AnfangsdatumLabel.Caption := WelcherMonat(anfangsMonat) + ' ' + IntToStr(anfangsJahr);
         RateTextLabel.Caption := 'Monatliche Rate';
     end
     else
     begin
         AnfangsdatumLabel.Caption := IntToStr(anfangsJahr);
         RateTextLabel.Caption := 'J�hrliche Rate';
     end;
     DarlehensbetragLabel.Caption := FloatToStrf(darlehen, ffFixed,6,2) + ' �';
     ZinssatzLabel.Caption := FloatToStrf(zinsSatz, ffFixed,6,2) + ' % pro Jahr';
     TilgungLabel.Caption := FloatToStrf(startTilgungsAnteil, ffFixed,6,2) + ' �';
     RateLabel.Caption := FloatToStrf(rate, ffFixed,6,2) + ' �';
     SummeZinsenLabel.Caption := FloatToStrf(ratenSumme - darlehen, ffFixed,6,2) + ' �';
     DatumLabel.Caption := periode;

     //Erstellen des Graphen

     //Labels
     anzahlMonate := 12*(-anfangsJahr + Jahr) + Abs(-anfangsMonat + monat);
     erstesDrittel := Math.Ceil(anzahlMonate / 3);
     zweitesDrittel := Math.Ceil(2 * (anzahlMonate / 3));

     if(IsMonat = true) then
     begin
         GesamtlaufzeitLabel.Caption :=  IntToStr(-anfangsJahr + Jahr) + ' Jahr(e) ' + IntToStr(Abs(-anfangsMonat + monat)) + ' Monat(e)';
         ErstesDatumLabel.Caption := WelcherMonat(anfangsMonat) + ' ' + IntToStr(anfangsJahr);
         LetztesDatumLabel.Caption := WelcherMonat(Monat) + ' ' + IntToStr(Jahr);
         ZweitesDatumLabel.Caption := WelcherMonat((erstesDrittel mod 12) + 1) + ' ' + IntToStr(anfangsJahr + Trunc(erstesDrittel/12));
         DrittesDatumLabel.Caption := WelcherMonat((zweitesDrittel mod 12) + 1) + ' ' + IntToStr(anfangsJahr + Trunc(zweitesDrittel/12));
     end
     else
     begin
         GesamtlaufzeitLabel.Caption :=  IntToStr(-anfangsJahr + Jahr) + ' Jahr(e)';
         ErstesDatumLabel.Caption := IntToStr(anfangsJahr);
         LetztesDatumLabel.Caption := IntToStr(Jahr);
         ZweitesDatumLabel.Caption := IntToStr(anfangsJahr + Trunc(erstesDrittel/12));
         DrittesDatumLabel.Caption := IntToStr(anfangsJahr + Trunc(zweitesDrittel/12));
     end;

     ErstesDarlehenLabel.Caption := FloatToStrf(DarlehenDatenArray[0], ffFixed,6,2) + ' �';
     ZweitesDarlehenLabel.Caption := FloatToStrf(2 *(DarlehenDatenArray[0] / 3), ffFixed,6,2) + ' �';
     DrittesDarlehenLabel.Caption := FloatToStrf(DarlehenDatenArray[0]/3, ffFixed,6,2) + ' �';

     //Zeichnen
     GraphFeld.Refresh;
     ZeichneGraph();

     Tabelle.RowCount := reihe;
end;

procedure TForm1.TabelleZuruecksetzen();
var i: integer;
begin
   for i := 0 to Tabelle.ColCount - 1 do
       Tabelle.Cols[i].Clear;

   Tabelle.Cells [0,0] := 'Periode';
   Tabelle.Cells [1,0] := 'Rate, �';
   Tabelle.Cells [2,0] := 'Zinsanteil, �' ;
   Tabelle.Cells [3,0] := 'Tilgungsanteil, �';
   Tabelle.Cells [4,0] := 'Restschuld, �' ;
end;

function TForm1.WelcherMonat(index :integer): string;
begin
  case index of
    1: result := 'Januar';
    2: result := 'Februar';
    3: result := 'M�rz';
    4: result := 'April';
    5: result := 'Mai';
    6: result := 'Juni';
    7: result := 'Juli';
    8: result := 'August';
    9: result := 'September';
    10: result := 'Oktober';
    11: result := 'November';
    12: result := 'Dezember';
  else result := 'NN';
  end;
end;

procedure TForm1.ZeichneGraph();
var vertikaleSkalierung, horizontaleSkalierung :double;
    i,x1,y1,x2,y2 :integer;
begin
      with GraphFeld.Canvas do
      begin
          Brush.Style := bsSolid;
          //Koordinatenkreuz
          Pen.Color := clBlack;
          MoveTo(0, GraphFeld.Height - 2);
          LineTo(GraphFeld.Width, GraphFeld.Height - 2);
          MoveTo(0, 0);
          LineTo(GraphFeld.Width, 0);
          MoveTo(0, GraphFeld.Height);
          LineTo(0,0);
          MoveTo(GraphFeld.Width - 2, GraphFeld.Height);
          LineTo(GraphFeld.Width - 2,0);

          Pen.Color := clWhite;
          MoveTo(0, Round((GraphFeld.Height - 2)/3));
          LineTo(GraphFeld.Width, Round((GraphFeld.Height - 2)/3));
          MoveTo(0, Round((GraphFeld.Height - 2)/3 * 2));
          LineTo(GraphFeld.Width, Round((GraphFeld.Height - 2)/3 * 2));

          MoveTo(Round((GraphFeld.Width - 2)/3), GraphFeld.Height);
          LineTo(Round((GraphFeld.Width - 2)/3),0);
          MoveTo(Round(((GraphFeld.Width - 2)/3) *2), GraphFeld.Height);
          LineTo(Round(((GraphFeld.Width - 2)/3) *2),0);

          //Graph
          if(BerechnungAbgeschlossen = true) then
          begin
              vertikaleSkalierung := DarlehenDatenArray[0] / GraphFeld.Height;
              horizontaleSkalierung := GraphFeld.Width / High(DarlehenDatenArray);

              Pen.Color := clBlue;
              for i := 1 to High(DarlehenDatenArray) do
              begin
                 x1 := Round((i-1)*horizontaleSkalierung);
                 y1 := Round(GraphFeld.Height - (DarlehenDatenArray[i - 1]/ vertikaleSkalierung));
                 x2 := Round(i*horizontaleSkalierung);
                 y2 := Round(GraphFeld.Height - (DarlehenDatenArray[i]/ vertikaleSkalierung));

                 if(y1 <= GraphFeld.Height - 2) then
                 begin
                     MoveTo(x1, y1);
                     LineTo(x2, y2);
                 end;
              end;
          end;
      end;
end;

procedure TForm1.TabsTeilChange(Sender: TObject);
begin
   if(TabsTeil.ActivePage.Name = 'Graph') then ZeichneGraph();
end;

//Ab hier werden Eingaben auf G�ltigkeit �berpr�ft
procedure TForm1.KannBerechnen();
begin
  if( (DarlehenVeraendert = true) and (ZinssatzVeraendert = true) and
      (TilgungVeraendert  = true) and (RatenArtVeraendert = true) and
      (AnfangsmonatVeraendert = true) and (AnfangsJahrVeraendert = true)) then
          BerechnenButton.Enabled := true
  else BerechnenButton.Enabled := false;
end;

procedure TForm1.JahrOderMonatComboBoxChange(Sender: TObject);
begin
  RatenArtVeraendert := true;
  if (JahrOderMonatComboBox.ItemIndex = 0) then
  begin
      IsMonat := true;
      MonatComboBox.Enabled := true;
  end
  else
  begin
     AnfangsmonatVeraendert := true;
     IsMonat := false;
     MonatComboBox.Enabled := false;
  end;
  KannBerechnen();
end;

procedure TForm1.MonatComboBoxChange(Sender: TObject);
begin
  AnfangsmonatVeraendert := true;
  KannBerechnen();
end;

procedure TForm1.DarlehenEditBoxChange(Sender: TObject);
var s :string;
begin
   if(GueltigeEingabe(DarlehenEditBox.Text, true) = true) then
   begin
      DarlehenVeraendert := true;
      KannBerechnen();
   end
   else DarlehenEditBox.Text := LetzteEingabeLoeschen(DarlehenEditBox.Text);
end;

procedure TForm1.ZinssatzEditBoxChange(Sender: TObject);
begin
   if(GueltigeEingabe(ZinssatzEditBox.Text, true) = true) then
   begin
      ZinssatzVeraendert := true;
      KannBerechnen();
   end else ZinssatzEditBox.Text := LetzteEingabeLoeschen(ZinssatzEditBox.Text);
end;

procedure TForm1.TilgungsSatzEditBoxChange(Sender: TObject);
begin
   if(GueltigeEingabe(TilgungsSatzEditBox.Text, true) = true) then
   begin
      TilgungVeraendert  := true;
      KannBerechnen();
   end else TilgungsSatzEditBox.Text := LetzteEingabeLoeschen(TilgungsSatzEditBox.Text);
end;

procedure TForm1.AnfangsJahrEditBoxChange(Sender: TObject);
begin
  if(GueltigeEingabe(AnfangsJahrEditBox.Text, false) = true) then
  begin
      AnfangsJahrVeraendert := true;
      KannBerechnen();
  end else AnfangsJahrEditBox.Text := LetzteEingabeLoeschen(AnfangsJahrEditBox.Text);
end;

function TForm1.LetzteEingabeLoeschen(s :string): string;
begin
   Delete(s, Length(s), 1);
   result := s;
end;

function TForm1.GueltigeEingabe(eingabe :string; istGleitkommawert :boolean) : boolean;
var test :double;
begin
  if(istGleitkommawert = true) then
  begin
      try
      begin
         if not(eingabe = '') then
             test:= StrToFloat(eingabe);
         result := true;
      end;
      except
         ShowMessage('Fehler. Kein g�ltiger Gleitkommawert');
         result :=false;
      end;
  end
  else
  begin
      try
      begin
         if not(eingabe = '') then
             test:= StrToInt(eingabe);
         result := true;
      end;
      except
         ShowMessage('Fehler. Kein g�ltiger Integerwert');
         result :=false;
      end
  end;
end;


procedure TForm1.Button1Click(Sender: TObject);
begin
  close();
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
   ShowMessage('By Mohammed El-Nabulsi');
end;


end.
