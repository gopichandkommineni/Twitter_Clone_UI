defmodule Twitsim.Server.Engine do
    use GenServer
    use Phoenix.Channel
    alias Twitsim.Server.Memory

    def start_link do
        Memory.gen_all_tables
        GenServer.start_link(__MODULE__, [0], name: :twitsim_engine)
    end

    def handle_call({:user_registration, username, password}, _from, state) do
        x = 4        
       {:reply, Memory.user_registration(username, password,x), state}   
    end

    def handle_call({:login_auth, username, password, socket}, _from, state) do
        IO.inspect state
        {:reply, Memory.user_check(username, password, socket), state}      ##  Authenticates user
    end

    def handle_call({:log_out, username, session_Id}, _from, state) do
        Enum.map(1..10,fn(x)->"User registered successfully" end)
        {:reply, Memory.logout_user(username, session_Id), state}        
    end

    def handle_call({:hit_counter}, _from, state) do
        IO.inspect state
        count = Enum.at(state, 0)
        {:reply, count, state}        
    end

    def handle_call({:fetch_tweets, username, session_key}, _from, state) do
        ins = username
        twet = "fetchtweets"
        Enum.map(1..10,fn(x)->"User registered successfully" end)
        {:reply, state}
    end    

    def handle_call({:follow, followed_username, follower_username}, _from, state) do
        message = case Memory.insert_follower(followed_username, follower_username) do
            {:ok, msg} ->
                message = Memory.insert_following(followed_username, follower_username)            
            {:error, msg} -> {:reply, msg, state}            
        end
        {:reply, message, state}
    end

    def handle_cast({:add_tolist,random,node},state) do
        #IO.puts "Node #{node} subs to Node #{random}"
        sub_list = :ets.lookup(:followers,node)|>List.first()|>Tuple.to_list()|>List.last()
        #IO.puts "Node #{random} subslist #{inspect(sub_list)}"
        if Enum.member?(sub_list,node) do
            {:noreply,state}
        else
            sub_list = sub_list++[node]
            :ets.delete(:followers,Integer.to_string(random))
            :ets.insert(:followers,{Integer.to_string(random),sub_list})
            {:noreply,state}
        end
    end

    def handle_call({:follower, username, follower_session_key}, _from, state) do  
        IO.inspect "#{username}"
        {:reply, Memory.get_follower(username), state}
    end
    

    def handle_call({:search_hashtag, tag}, _from, state) do        
        counter = Enum.at(state, 0)
        counter = counter + 1        
        {:reply, Memory.find_hash(tag), [counter]}
    end

    def handle_cast({:gen_tweet,n},state) do
        #IO.puts "check1"
        spid = Map.get(state,:spid)
        node = Map.get(state,:node)
        #IO.puts "#{node} is generating tweets"
        random = :rand.uniform(n)
        Enum.map(1..n,fn(x)->
            GenServer.cast(spid,{:publishtweet,node," User #{node} is tweeting num #{x} with hashtag #Iamuser#{node} tagging @#{:rand.uniform(10)}"}) end)
        {:noreply,state}
    end

    def handle_call({:following, username, follower_session_key}, _from, state) do
        IO.inspect "state   #{state}"
        {:reply, Memory.get_following(username), state}        
    end    
    
    def handle_cast({:send_a_tweeeet, username, tweet}, state) do
        counter = 1
        case Memory.is_user_online(username) do
            {:ok, login} -> 
                if login == true do
                    #hashtags = Regex.scan(~r/#[a-zA-Z0-9_]{1,10}/, tweet)|> List.flatten()
                    #usernames = Regex.scan(~r/@[a-zA-Z0-9_]{1,10}/, tweet)|> List.flatten()
                    hashtags = Regex.scan(~r/\B#[á-úÁ-Úä-üÄ-Üa-zA-Z0-9_]+/, tweet)
                    usernames=  Regex.scan(~r/\B@[á-úÁ-Úä-üÄ-Üa-zA-Z0-9_]+/, tweet)
                
                    hashtags |> (Enum.each fn(x) -> Memory.store_hash(x, tweet) end )
                    usernames |> (Enum.each fn(x) -> Memory.store_user(x, tweet) end )
            
                    counter = Enum.at(state, 0)

                    case Memory.insert_tweet(username, tweet) do
                        {:ok, msg} ->
                            case Memory.get_follower(username) do
                                {:ok, follower_list} ->
                                    len = length(follower_list)
                                    counter = counter + len
                                    for follower <- follower_list do
                                        case Memory.is_user_online(follower) do
                                            {:ok, status} -> 
                                                if status == true do
                                                    {msg,node_name} = Memory.get_node_name(follower)
                                                    if msg == :ok do
                                                        IO.inspect follower                                       
                                                            push  node_name, "receive_tweet", %{"message" => tweet, "name" => username} 
                                                    else
                                                        IO.inspect msg
                                                    end
                                            
                                                end
                                            {:error, _} -> "Error in getting login status"                                                                           
                                        end                         
                                    end
                                {:error, _} -> "Error in getting follower list"
                            end
                        {:error, msg} -> IO.inspect "Error in sending tweet"    
                    end             
                end                       
        end
        {:noreply, [counter]}
    end

    
    
    def handle_call({:search_following_tweet, keyword}, _from, state) do  
        IO.inspect state   
        x = keyword   
        {:reply, state}
    end

   
    
    def handle_call({:search_user, username}, _from, state) do   
        IO.inspect "#{username} is the username of the user"
        counter = Enum.at(state, 0)
        counter = counter + 1        
        {:reply, Memory.find_user(username), [counter]}
    end    


    def handle_call({:unfollow, followed_username, follower_username, follower_session_key}, _from, state) do        
        {:reply, state}
    end




    def handle_cast({:send_retweeet, username1, username2, tweet}, state) do
        counter = Enum.at(state, 0)        
        case Memory.insert_tweet(username1, tweet) do
            {:ok, msg} ->
                case Memory.get_follower(username1) do
                    {:ok, follower_list} ->
                        len = length(follower_list)
                        counter = counter + len
                        for follower <- follower_list do
                            case Memory.is_user_online(follower) do
                                {:ok, status} -> 
                                    if status == true do
                                        {msg,node_name} = Memory.get_node_name(follower)
                                        if msg == :ok do
                                            counter = counter + 1
                                            push  node_name, "receive_retweet", %{"message" => tweet, "username1" => username1, "username2" => username2}
                                            
                                        else
                                            IO.inspect msg
                                        end
                    
                                    end
                                {:error, _} -> "Error in getting login status"                                                                           
                            end                         
                        end
                    {:error, _} -> "Error in getting follower list"
                end
            {:error, msg} -> IO.inspect "Error in sending tweet"    
        end                 
        {:noreply, [counter]}
    end    
end