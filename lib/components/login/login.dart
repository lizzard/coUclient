library login;

import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:firebase/firebase.dart';
import 'dart:async';
import 'dart:convert';

import 'package:couclient/configs.dart';

@CustomTag('ur-login')
class UrLogin extends PolymerElement
{
	String _authUrl = 'https://${Configs.authAddress}/auth';
	@published bool newUser;
	@observable bool timedout, newSignup = false, waiting = false;
	@observable String email, password, newEmail = '', newUsername = '', newPassword = '';
	Firebase firebase;

	UrLogin.created() : super.created()
	{
		firebase = new Firebase("https://blinding-fire-920.firebaseio.com");
	}

	loginAttempt(event, detail, target) async
	{
		waiting = true;
		Map<String,String> credentials = {'email':email,'password':password};

    	try
    	{
    		Map response = await firebase.authWithPassword(credentials);
    		print('user logged in: $response');
    	}
    	catch(err)
    	{
    		print(err);
    	}
    	finally
    	{
    		waiting = false;
    	}
	}

	usernameSubmit(event, detail, target) async
	{
		if(newUsername == '' || newPassword == '')
			return;

		try
    	{
			await firebase.createUser({'email':newEmail,'password':newPassword});
			dispatchEvent(new CustomEvent('setUsername', detail: newUsername));
    	}
    	catch(err)
    	{
    		print("couldn't create user on firebase: $err");
    	}
	}

	void signup(event, detail, target)
	{
		newSignup = true;
	}

	verifyEmail(event, detail, target) async
	{
		waiting = true;

		Timer tooLongTimer = new Timer(new Duration(seconds: 5),() => timedout = true);

		HttpRequest request = await HttpRequest.request(_authUrl + "/verifyEmail", method: "POST",
				requestHeaders: {"content-type": "application/json"},
				sendData: JSON.encode({'email':newEmail}));

		tooLongTimer.cancel();

		Map result = JSON.decode(request.response);
		if(result['result'] != 'OK')
		{
			waiting = false;
			print(result);
			return;
		}

		WebSocket ws = new WebSocket("ws://${Configs.authWebsocket}/awaitVerify");
		ws.onOpen.first.then((_)
		{
			Map map = {'email':newEmail};
			ws.send(JSON.encode(map));
		});
		ws.onMessage.first.then((MessageEvent event)
		{
			Map map = JSON.decode(event.data);
			if(map['result'] == 'success')
			{
				dispatchEvent(new CustomEvent('loginSuccess', detail: map['serverdata']));
			}
			else
			{
				print('problem verifying email address: ${map['result']}');
			}
			waiting = false;
		});
	}
}