//--------------------------------------------------------------------
// mistaken.mq4 
// ������������ ��� ������������� � �������� ������� � �������� MQL4.
//--------------------------------------------------------------------
int start()                                     // ����. ������� start
  {                                             // �������� BUY
   OrderSend(Symbol(),OP_BUY,0.1,Bid,3,Bid-15.5*Point,Bid+15*Point);
   Alert (GetLastError());                      // ��������� �� ������
   return;                                      // ����� �� start()
  }
//--------------------------------------------------------------------