part of couclient;

String SLACK_TEAM;
String SLACK_TOKEN;
String SC_TOKEN;

String SESSION_TOKEN;
String FORUM_TOKEN;

class AuthManager {
  String _authUrl = 'https://server.childrenofur.com:8383/auth';

  Persona _personaNavigator;
  Element _loginPanel;

  AuthManager() {
    // Starts the game
    _loginPanel = querySelector('ur-login');
    
    _personaNavigator = new Persona('', verifyWithServer, view.loggedOut);
    _loginPanel.on['attemptLogin'].listen((_) {
      _personaNavigator.request({
        'backgroundColor': '#4b2e4c',
        'siteName': 'Children of Ur'
      });
      //_loginButton.hidden = true;
    });
  }

  
  void verifyWithServer(String personaAssertion) {

    Timer tooLongTimer = new Timer(new Duration(seconds: 5),(){
      SpanElement greeting = querySelector('#greeting');
      greeting.text = '''
Oh no!
Looks like the server is a bit slow. 
Please check back another time. :(''';
    });

    HttpRequest.request(_authUrl + "/login", method: "POST", requestHeaders: {
      "content-type": "application/json"
    }, sendData: JSON.encode({
      'assertion': personaAssertion,
      'audience' : 'http://localhost:8080/index.html'
      //'audience':'http://robertmcdermot.com/cou:80'
    }))
      ..then((HttpRequest data) {
      tooLongTimer.cancel();
      Map serverdata = JSON.decode(data.response);
      
      if (serverdata['ok'] == 'no') {
        print('Error:Server refused the login attempt.');
        return;
      }
      
      SESSION_TOKEN = serverdata['sessionToken'];
      SLACK_TEAM = serverdata['slack-team'];
      SLACK_TOKEN = serverdata['slack-token'];
      SC_TOKEN = serverdata['sc-token'];
      
      
      if (serverdata['playerName'].trim() == '') {
        setupNewUser(serverdata);
      }
      else {
        // Get our username and location from the server.
        sessionStorage['playerName'] = serverdata['playerName'];
        sessionStorage['playerStreet'] = serverdata['playerStreet'];
        startGame(serverdata);
      }
    });
  }

  void logout() {
      _personaNavigator.logout();
      window.location.reload();
  }
  
  
  startGame(Map serverdata) {
    if (serverdata['ok'] == 'no') {
      print('Error:Server refused the login attempt.');
      return;
    }

    // Begin Game//
    game = new Game();
    audio = new SoundManager();
    inputManager = new InputManager();
    view.loggedIn();
  }
  
  setupNewUser(Map serverdata) {
    Element signinElement = querySelector('ur-login');
    signinElement.attributes['newuser'] = 'true';
    signinElement.on['setUsername'].listen((_) {
      
      HttpRequest.postFormData('https://server.childrenofur.com:8383/auth', {
        'type' : 'set-username',
        'token': SESSION_TOKEN,
        'username' : (signinElement.shadowRoot.querySelector('#new-user-name') as InputElement).value
      }).then((HttpRequest request) {
        print(request.responseText);
        
        if (request.responseText == '{"ok":"true"}') {
          // now that the username has been set, refresh and auto-login.
          window.location.reload();
          }
      });
    });

  }

}







