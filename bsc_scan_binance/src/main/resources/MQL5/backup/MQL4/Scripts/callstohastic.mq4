//--------------------------------------------------------------------
// callstohastic.mq4
// ������������ ��� ������������� � �������� ������� � �������� MQL4.
//--------------------------------------------------------------------
int start()                       // ����. ������� start
  {
   double M_0, M_1,               // �������� MAIN �� 0 � 1 �����
   S_0, S_1;               // �������� SIGNAL �� 0 � 1�����
//--------------------------------------------------------------------
   // ��������� � ������� ����.�������.
   M_0=iStochastic(NULL,0,5,3,3,MODE_SMA,0,MODE_MAIN,  0);// 0 ���
   M_1=iStochastic(NULL,0,5,3,3,MODE_SMA,0,MODE_MAIN,  1);// 1 ���
   S_0=iStochastic(NULL,0,5,3,3,MODE_SMA,0,MODE_SIGNAL,0);// 0 ���
   S_1=iStochastic(NULL,0,5,3,3,MODE_SMA,0,MODE_SIGNAL,1);// 1 ���
//--------------------------------------------------------------------
   // ������ ��������
   if(M_1 < S_1 && M_0>=S_0) // ������� ���������� ������� �����
      Alert("����������� ����� �����. �������."); // ��������� 
   if(M_1 > S_1 && M_0<=S_0) // ������� ���������� ������� �����
      Alert("����������� ������ ����. �������."); // ��������� 

   if(M_1 > S_1 && M_0 > S_0)  // ������ ���� �������
      Alert("���������� ������� �������.");       // ��������� 
   if(M_1 < S_1 && M_0 < S_0)  // ������ ���� �������
      Alert("���������� ������� �������.");       // ��������� 
//--------------------------------------------------------------------
   return;                            // ����� �� start()
  }
//--------------------------------------------------------------------