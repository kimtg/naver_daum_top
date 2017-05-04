unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, regexpr, fphttpclient;

type

  { TForm1 }

  TForm1 = class(TForm)
    Memo1: TMemo;
    Timer1: TTimer;
    procedure Timer1Timer(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

  astring = array of string;

var
  hc: tfphttpclient;
  x: string;
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
  text: string;
begin
  re := tregexpr.Create('<span class="ah_k">(.+?)</span>');
  text := hc.get('http://www.naver.com');
  list_naver := re_groups(re, text, 1);
  re.Free;
end;

function list_daum: astring;
var
  re: tregexpr;
  text: string;
begin
  re := tregexpr.Create('class="link_issue">(.+?)</a>');
  text := hc.get('http://www.daum.net');
  list_daum := re_groups(re, text, 1);
  re.free;
end;

{ TForm1 }

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  memo1.Append(DateTimeToStr(Now));
  memo1.Text := memo1.Text + 'Naver: ';
  for x in list_naver do
      memo1.Text := memo1.Text + x + ',';
  memo1.Append('');
  memo1.Text := memo1.Text + 'Daum: ';
  for x in list_daum do
      memo1.Text := memo1.Text + x + ',';
  memo1.Append('');
end;

begin
  hc := tfphttpclient.create(nil);
  hc.AllowRedirect := true;
end.

