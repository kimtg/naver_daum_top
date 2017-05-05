unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, regexpr, fphttpclient;

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

  astring = array of string;

var
  Form1: TForm1;

implementation

{$R *.lfm}

function re_groups(re: tregexpr; text: string; group: integer): astring;
var
  r: astring;
begin
  if re.Exec(text) then
  begin
     setlength(r, 1);
     r[0] := re.Match[group];
     while re.ExecNext do
     begin
       setlength(r, length(r) + 1);
       r[length(r) - 1] := re.match[group];
     end;
  end;
  re_groups := r;
end;


function list_naver: astring;
var
  re: tregexpr;
begin
  re := tregexpr.Create('<span class="ah_k">(.+?)</span>');
  list_naver := re_groups(re, TFPHTTPClient.SimpleGet('https://www.naver.com'), 1);
  SetLength(list_naver, 20);
  re.Free;
end;

function list_daum: astring;
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
  x: string;
begin
  memo1.Append(DateTimeToStr(Now));
  memo1.Text := memo1.Text + 'Naver: ';
  for x in list_naver do
    memo1.Text := memo1.Text + x + ',';
  memo1.Text := memo1.Text + #10 + 'Daum: ';
  for x in list_daum do
    memo1.Text := memo1.Text + x + ',';
  memo1.Append('');
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

end.

