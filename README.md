# DOS Project 4.2

Gopichand Kommineni         UFID 0305-5523
Hemanth Kumar Malyala       UFID 6348-5914


# Twitter Engine

 Twitter is a messaging service where users post and interact with messages known as "tweets".  
 Registered users can post, and retweet tweets, but unregistered users can only read them. 
 Users can group posts together by topic or type by use of hashtags – words or phrases prefixed with a 
 “#” sign. Similarly, the “@” sign followed by a username is used for mentioning or replying to other users.
 To repost a message from another Twitter user and share it with one's own followers, a user can click the 
 retweet button within the Tweet. 
 
 
	Project demo link: https://youtu.be/y9aJUzgJeeo
 
#To start Phoenix server:

	1) Install dependencies with mix deps.get
	2) Create and migrate database with mix ecto.create && mix ecto.migrate
	3) Install Node.js dependencies with cd assets && npm install
	4) Start Phoenix endpoint with mix phx.server
	
		The application will be running on localhost:4000 of the browser.
		
#Implementation:

	we have implemented the following functionalities in our Twitter UI application:
	
	Registering the user
	User log in
	Send a tweet
	Follow users
	Search query by hashtag
	Search query by mention
	Re-tweet functionality
	
	
# Bonus Implementation:
		
	We have implemented the user authentication.
	A User will not be able to login if he is not registered earlier with a user name and password.
	Also, he won't be able to login with incorrect credentials.
		
		
	Official website: http://www.phoenixframework.org/
	Guides: http://phoenixframework.org/docs/overview
	Docs: https://hexdocs.pm/phoenix
	Mailing list: http://groups.google.com/group/phoenix-talk
	Source: https://github.com/phoenixframework/phoenix