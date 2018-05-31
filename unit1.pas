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

var
  re_naver, re_daum: tregexpr;

function re_groups(re: tregexpr; text: string; group: integer): string;
var
  count : longint = 0;
begin
  re_groups := '';
  if re.Exec(text) then
  begin
    repeat
      inc(count);
      if count > 20 then break;
      re_groups := re_groups + re.match[group] + '; ';
    until not re.ExecNext;
  end;
end;

function list_naver: string;
begin
  list_naver := re_groups(re_naver, TFPHTTPClient.SimpleGet('https://www.naver.com'), 1);
end;

function list_daum: string;
begin
  list_daum := re_groups(re_daum, TFPHTTPClient.SimpleGet('https://www.daum.net'), 1);
end;

{ TForm1 }

procedure TForm1.Timer1Timer(Sender: TObject);
var
  item: string;
begin
  try
    item := DateTimeToStr(Now);
    item := item + LineEnding + 'Naver: ' + list_naver;
    item := item + LineEnding + 'Daum: ' + list_daum + LineEnding;
  except
    on e: Exception do
      item := item + e.ToString;
  end;
  result.Add(item);
  while result.Count > 10000 do
    result.Delete(0);

  memo1.Text := result.Text;
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

begin
  re_naver := tregexpr.Create('<span class="ah_k">(.+?)</span>');
  re_daum := tregexpr.Create('class="link_issue" tabindex.*?>(.+?)</a>');
  result := TStringList.Create;
end.

