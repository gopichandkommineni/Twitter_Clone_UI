defmodule Twitsim.LobbyChannel do
    use Phoenix.Channel
    alias Twitsim.Memory
  
    def join("lobby", _payload, socket) do
      {:ok, socket}
    end
  
    def handle_in("register", payload, socket) do          
      username = Map.get(payload, "name")
      password = Map.get(payload, "password")
      {:ok, msg} =  GenServer.call(:twitsim_engine, {:user_registration, username, password})
      push  socket, "register_response", %{"message" => msg}      
      {:noreply, socket}
    end

    def handle_in("login", payload, socket) do
      username = Map.get(payload, "name")
      password = Map.get(payload, "password")
      {:ok,msg} = GenServer.call(:twitsim_engine, {:login_auth, username, password, socket})
      push  socket, "login_response", %{"message" => msg}
      {:noreply, socket}
    end
    
    def handle_in("logout", payload, socket) do
      username = Map.get(payload, "name")      
      IO.inspect  GenServer.call(:twitsim_engine, {:log_out, username, socket})
      {:noreply, socket}
    end

    def handle_in("follow", payload, socket) do
      followed_username = Map.get(payload, "following")
      follower_username = Map.get(payload, "follower")      
       {:ok, msg} = GenServer.call(:twitsim_engine, {:follow, followed_username, follower_username})       
      push  socket, "follow_response", %{"message" => msg}
      {:noreply, socket}
    end

    def handle_in("send_tweet", payload, socket) do
      username = Map.get(payload, "name")
      tweet = Map.get(payload, "tweet")      
      IO.inspect  GenServer.cast(:twitsim_engine, {:send_a_tweeeet, username, tweet})
      {:noreply, socket}
    end       

    def handle_in("send_retweet", payload, socket) do
      username1 = Map.get(payload, "username1")
      username2 = Map.get(payload, "username2")
      tweet = Map.get(payload, "tweet")            
      IO.inspect  GenServer.cast(:twitsim_engine, {:send_retweeet, username1, username2, tweet})
      {:noreply, socket}
    end    

    def handle_in("search_hashtag", payload, socket) do      
      hashtag = Map.get(payload, "hashtag")      
      response =  GenServer.call(:twitsim_engine, {:search_hashtag, hashtag})
      msg = "Search result for hashtag #{hashtag} : #{response}"
      push  socket, "receive_response", %{"message" => msg}
      {:noreply, socket}
    end  

    def handle_in("search_username", payload, socket) do
      username = Map.get(payload, "username")      
      response =  GenServer.call(:twitsim_engine, {:search_user, username})
      msg = "Search result for username #{username} : #{response}"
      push  socket, "receive_response", %{"message" => msg}
      {:noreply, socket}
    end  

    def handle_in("receive_tweet", payload, socket) do      
      {:noreply, socket}
    end

  end