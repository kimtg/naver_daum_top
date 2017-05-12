unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, RegExpr, fphttpclient;

type

  { TForm1 }

  TForm1 = class(TForm)
    ButtonRefresh: TButton;
    EditInterval: TEdit;
    Label1: TLabel;
    Memo1: TMemo;
    Timer1: TTimer;
    procedure ButtonRefreshClick(Sender: TObject);
    procedure EditIntervalChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;
  result: TStrings;

implementation

{$R *.lfm}

function re_groups(re: tregexpr; text: string; group: integer): TStrings;
begin
  re_groups := TStringList.Create;
  if re.Exec(text) then
  begin
     re_groups.Add(re.Match[group]);
     while re.ExecNext do
       re_groups.Add(re.match[group]);
  end;
end;


function list_naver: TStrings;
var
  re: tregexpr;
begin
  re := tregexpr.Create('<span class="ah_k">(.+?)</span>');
  list_naver := re_groups(re, TFPHTTPClient.SimpleGet('https://www.naver.com'), 1);
  list_naver.Capacity := 20;
  re.Free;
end;

function list_daum: TStrings;
var
  re: tregexpr;
begin
  re := tregexpr.Create('class="link_issue">(.+?)</a>');
  list_daum := re_groups(re, TFPHTTPClient.SimpleGet('http://www.daum.net'), 1);
  re.free;
end;

{ TForm1 }

procedure TForm1.Timer1Timer(Sender: TObject);
var
  x, item: string;
  ln, ld: TStrings;
begin
  try
    item := item + DateTimeToStr(Now);
    item := item + #13#10'Naver: ';
    ln := list_naver;
    for x in ln do
      item := item + x + '; ';
    ln.Free;

    item := item + #13#10'Daum: ';
    ld := list_daum;
    for x in ld do
      item := item + x + '; ';
    ld.Free;
    item := item + #13#10;
  except
    on e: Exception do
    begin
      item := item + e.ToString;
    end;
  end;
  result.Add(item);
  while result.Count > 10000 do
    result.Delete(0);
  memo1.Clear;
  for x in result do
    memo1.Append(x);
end;

procedure TForm1.EditIntervalChange(Sender: TObject);
begin
  Timer1.Interval := StrToInt(EditInterval.Text) * 1000;
end;

procedure TForm1.ButtonRefreshClick(Sender: TObject);
begin
  Timer1Timer(Nil);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  EditIntervalChange(Nil);
  Timer1Timer(Nil);
end;

begin
     result := TStringList.Create;
end.

