--[[
--NodeMCU���ӱ���������������Why������ʱ��2017.09.07
--��Ʒ˵����NodeMCU���ӵ����ǣ������Խ�������ƣ���Ҫ�ǿ���Ԥ�����ܣ���
--��Ԥ�����ܺ����������������͵���⴫������̽�ⷶΧ���Զ���ƽ̨����Ԥ����Ϣ��
--�ر�Ԥ�����򲻻ᴥ����
--Ϊ�˷�����ͺͲ鿴������ʱ����˺ܶ�ע�ͺͿ��еȣ�ʹ��ʱ����ɾ��
--]]

--�趨�뱴��������ص���Ϣ���豸ID��APIKEY��INPUTID�����Ƿ�������Ϣ��ip��port��
DEVICEID = "000"
APIKEY = "000000000"
INPUTID = "000"
host = "121.42.180.30"
port = 8181

--�趨����豸��ӦIO��
Alert = 0--��������ǿ����Լ�NodeMCU����ָʾ��
Pir = 1--���͵���⴫����
LED = 4--NodeMCU����Wifiָʾ��,�˴���ΪԤ�������Ƿ�����ָʾ��

--�������IO��ģʽ�ͳ�ʼ��ƽ
gpio.mode(Alert, gpio.OUTPUT)
gpio.write(Alert, gpio.HIGH)
gpio.mode(Pir, gpio.OUTPUT)
gpio.write(Pir, gpio.LOW)
gpio.mode(LED, gpio.OUTPUT)
gpio.write(LED, gpio.HIGH)

--����һ��TCP����
cu = net.createConnection(net.TCP)

--��IP�Ͷ˿����ӵ�����
cu:connect(port, host)

--������֤��Ϣ������
ok, s = pcall(cjson.encode, {M="checkin",ID=DEVICEID,K=APIKEY})
cu:send(s.."\n")

--ʹ�����Ӻ���ÿ30���ӷ���һ����֤��Ϣ�����豸����
tmr.alarm(1, 30000, 1, function()
	cu:send(s.."\n")
end)

--TCP���ӽ��յ���Ϣ�Ļص�����������
cu:on("receive", function(cu, c)--����Ϊ���������Ӻͷ������ݣ���ֱ�����ô����ӻظ���Ϣ
	r = cjson.decode(c)--�����յ�����Ϣ����Ϣ�ṹ�������ɱ���ͳһ����
	if r.M == "say" then--�ж���Ϣ����
		--�ж���Ϣ����
		if r.C == "play" then--��Ԥ������
            gpio.write(LED, gpio.LOW)--����Ԥ��ָʾ��
			ok, played = pcall(cjson.encode, {M="say",ID="U000",C="turn on"})--����ظ���Ϣ
			cu:send( played.."\n" )--���ͻظ���Ϣ
            gpio.mode(Pir,gpio.INT)--�������͵���⴫�������ӵ�IO��Ϊ�ж�ģʽ
            gpio.trig(Pir, "both", function(level)--Ϊ�ж����ûص�����
                if level == gpio.HIGH then--��������
                    gpio.write(Alert, gpio.LOW)--�����������ⱨ��
					ok, warning = pcall (cjson.encode, { M = "say", ID = "D0000", C = "warning" })--����Ԥ����Ϣ
					cu:send (warning .. "\n")----����Ԥ����Ϣ
				elseif level == gpio.LOW then--û�б�����Ϣ
					gpio.write (Alert, gpio.HIGH)--�رձ������ⱨ��
				end
            end)        
        elseif r.C == "stop" then--�ر�Ԥ������
			gpio.write (LED, gpio.HIGH)--Ϩ��Ԥ��ָʾ��
			gpio.write (Alert, gpio.HIGH)--�رձ������ⱨ��
			gpio.mode (Pir, gpio.OUTPUT)--�������͵���⴫�������ӵ�IO��Ϊ���ģʽ�����ر����жϹ���
			ok, stoped = pcall (cjson.encode, { M = "say", ID = "U000", C = "turn off" })--����ظ���Ϣ
			cu:send (stoped .. "\n")--���ͻظ���Ϣ
		end
    end
end)

--TCP���ӱ��Ͽ��Ļص�����������
cu:on('disconnection',function()
	--Do something here what you want to do
end)