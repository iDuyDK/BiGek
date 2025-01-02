//--------------------------------------------------------------------
// timetablenews.mq4
// ������������ ��� ������������� � �������� ������� � �������� MQL4.
//--------------------------------------------------------------- 1 --
int start()                            // ����. ������� start
  {
//--------------------------------------------------------------- 2 --
   int Handle,                         // �������� ���������
       Stl;                            // ����� ������������ �����
   string File_Name="News.csv",        // ��� �����
          Obj_Name,                    // B�� �������
          Instr,                       // �������� ������
          One,Two,                     // 1� � 2� ���� �������� �����.
          Text,                        // ����� �������� �������
          Str_DtTm;                    // ���� � ����� �������(������)
   datetime Dat_DtTm;                  // ���� � ����� �������(����)
   color Col;                          // ���� ������������ �����
//--------------------------------------------------------------- 3 --
   Handle=FileOpen(File_Name,FILE_CSV|FILE_READ,";");// �������� �����
   if(Handle<0)                        // ������� ��� �������� �����
     {
      if(GetLastError()==4103)         // ���� ����� �� ����������,..
         Alert("��� ����� � ������ ",File_Name);//.. �������� �������� 
      else                             // ��� ����� ������ ������..
         Alert("������ ��� �������� ����� ",File_Name);//..����� �����
      PlaySound("Bzrrr.wav");          // �������� �������������
      return;                          // ����� �� start()      
     }
//--------------------------------------------------------------- 4 --
   while(FileIsEnding(Handle)==false)// �� ��� ���, ���� �������� ..
     {                                // ..��������� �� � ����� �����
      //--------------------------------------------------------- 5 --
      Str_DtTm =FileReadString(Handle);// ���� � ����� �������(����)
      Text     =FileReadString(Handle);// ����� �������� �������
      if(FileIsEnding(Handle)==true)   // �������� ��������� � �����
         break;                        // ����� �� ������ � ���������
      //--------------------------------------------------------- 6 --
      Dat_DtTm =StrToTime(Str_DtTm);   // �������������� ���� ������
      Instr    =StringSubstr(Text,0,3);// ��������� ������ 3 �������
      One=StringSubstr(Symbol(),0,3);// ��������� ������ 3 �������
      Two=StringSubstr(Symbol(),3,3);// ��������� ������ 3 �������
      Stl=STYLE_DOT;                   // ��� ���� - ����� �������
      Col=DarkOrange;                  // ��� ���� - ���� �����
      if(Instr==One || Instr==Two)     // � ��� ������� �� ������ ..
        {                             // .. ����������� �����������..
         Stl=STYLE_SOLID;              // .. ����� �����..
         Col=Red;                      // .. � ����� ���� ����. �����
        }
      //--------------------------------------------------------- 7 --
      Obj_Name="News_Line  "+Str_DtTm;     // ��� �������
      ObjectCreate(Obj_Name,OBJ_VLINE,0,Dat_DtTm,0);//������� ������..
      ObjectSet(Obj_Name,OBJPROP_COLOR, Col);       // ..� ��� ����,..
      ObjectSet(Obj_Name,OBJPROP_STYLE, Stl);       // ..�����..
      ObjectSetText(Obj_Name,Text,10);              // ..� �������� 
     }
//--------------------------------------------------------------- 8 --
   FileClose( Handle );                // ��������� ����
   PlaySound("bulk.wav");              // �������� �������������
   WindowRedraw();                     // �������������� �������
   return;                             // ����� �� start()
  }
//--------------------------------------------------------------- 9 --