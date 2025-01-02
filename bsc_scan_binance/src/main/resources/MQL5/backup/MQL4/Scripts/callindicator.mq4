//--------------------------------------------------------------------
// callindicator.mq4
// ������������ ��� ������������� � �������� ������� � �������� MQL4.
//--------------------------------------------------------------------
//--------------------------------------------------------------------
extern int Period_MA=5;             // ������ ��������� ��
bool Fact_Up=true;                  // ���� ���������, ��� ����..
bool Fact_Dn=true;                  //..��������� ���� ��� ���� ��
//--------------------------------------------------------------------
int start()                           // ����. ������� start
  {
   double MA;                         // �������� �� �� 0 ����    
//--------------------------------------------------------------------
   // ��������� � ������� ����.���.
   MA=iMA(NULL,0,Period_MA,0,MODE_SMA,PRICE_CLOSE,0);
//--------------------------------------------------------------------
   if (Bid > MA && Fact_Up==true)   // �������� ������� �����
     {
      Fact_Dn=true;                 // �������� � ���� ���� ��
      Fact_Up=false;                // �� �������� � ���� ���� ��
      Alert("���� ��������� ���� MA(",Period_MA,").");// ��������� 
     }
//--------------------------------------------------------------------
   if (Bid < MA && Fact_Dn==true)   // �������� ������� ����
     {
      Fact_Up=true;                 // �������� � ���� ���� ��
      Fact_Dn=false;                // �� �������� � ���� ���� ��
      Alert("���� ��������� ���� MA(",Period_MA,").");// ��������� 
     }
//--------------------------------------------------------------------
   return;                            // ����� �� start()
  }
//--------------------------------------------------------------------