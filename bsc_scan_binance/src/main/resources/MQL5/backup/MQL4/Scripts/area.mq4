//--------------------------------------------------------------------
// area.mq4
// ������������ ��� ������������� � �������� ������� � �������� MQL4.
//--------------------------------------------------------------------
int start()                             // ����������� ������� start()
  {
//--------------------------------------------------------------------
   int
   L,                                  // ����� ����
   S_etalon=1500000,                   // �������� ������� (��2)
   S,                                  // ������� ��������������
   a,b,s;                              // ������� ������� � �������
//--------------------------------------------------------------------
   while(true)                         // ������� ���� �� ������ ����
     {                                 // ������ �������� �����
      L=L+1000;                        // ������� �������� ���� � ��
      //--------------------------------------------------------------------
      S=0;                             // ��������� ��������.. 
      // ..��� ������� �������
      for(a=1; a<L/2; a++)             // ��������� ��������� �����
        {                              // ������ ����������� �����
         b=(L/2) - a;                  // ������� �������� ������
         s=a * b;                      // ������� �������� �������
         if (s<=S)                     // �������� ������� ��������
            break;                     // ����� �� ����������� �����
         S=s;                          // ���������� ������ ��������
        }                              // ����� ����������� �����
      //--------------------------------------------------------------------
      if (S>=S_etalon)                 // �������� ������� ��������
        {
         Alert("�������� ���� ������ ",L/1000," �.");// ��������� 
         break;                         // ����� �� �������� �����
        }
     }                                 // ����� �������� �����
//--------------------------------------------------------------------
   return;                              // �������� ������ �� �������
  }
//--------------------------------------------------------------------