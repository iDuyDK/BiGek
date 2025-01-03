//--------------------------------------------------------------------
// extremumprice.mq4 
// ������������ ��� ������������� � �������� ������� � �������� MQL4.
//--------------------------------------------------------------------
extern int Quant_Bars=30;                       // ���������� �����
//--------------------------------------------------------------------
int start()                                     // ����. ������� start
  {
   int i;                                       // ����� ���� 
   double Minimum=Bid,                          // ����������� ����
          Maximum=Bid;                          // ������������ ����

   for(i=0;i<=Quant_Bars-1;i++)                 // �� ���� (!) ��..
     {                                          // ..Quant_Bars-1 (!)
      if (Low[i]< Minimum)                      // ���� < ����������
         Minimum=Low[i];                        // �� ��� � ����� ���
      if (High[i]> Maximum)                     // ���� > ����������
         Maximum=High[i];                       // �� ��� � ����� ����
     }
   Alert("�� ��������� ",Quant_Bars,            // ����� �� �����  
         " ����� Min= ",Minimum," Max= ",Maximum);
   return;                                      // ����� �� start()
  }
//--------------------------------------------------------------------