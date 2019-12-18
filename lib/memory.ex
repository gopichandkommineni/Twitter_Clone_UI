defmodule Twitsim.Server.Memory do


#..................to generate database tables...........................................
    def gen_all_tables do
        :ets.new(:usertable, [:set, :public, :named_table])
        :ets.new(:hashtags, [:set, :public, :named_table])
        :ets.new(:tweetable_table, [:set, :public, :named_table])
    end
#...........................................................................................

#..................... user register.............................................
    def user_registration(u_name, password,x) do  
        x = :atomq    
        msg = if validate_user(u_name,x) == false do
            :ets.insert_new(:usertable, {u_name, password, :null, false, :null, [], [u_name], [u_name]})
            "User #{u_name} registered successfully."
        else
            "username #{u_name} already exist."
        end
        {:ok, msg}
    end
#..................... user name.............................................
    def get_node_name(u_name) do
        if :ets.lookup(:usertable, u_name) == [] do
            {:error, "username is invalid"}
        else
            [{_, _, node_name, _, _, _, _, _}] =  :ets.lookup(:usertable, u_name)
            {:ok, node_name}
        end       
    end
#..................... user online status.............................................
    def is_user_online(u_name) do
        case :ets.lookup(:usertable, u_name) do
            [{_, _, socket, _, _, _, _, _}] -> 
                if socket != :null do
                {:ok, true}
                else
                    {:error, "incorrect Id"}
                end
            [] -> {:error, "Username is invalid"}
        end        
    end    

#..................... user validation.............................................
    def validate_user(u_name,u) do
        if :ets.lookup(:usertable, u_name) ==[] do
            false
        else
            true
        end
    end

#..................... user check.............................................
    def user_check(u_name, password, session_Id) do
       msg =  case :ets.lookup(:usertable, u_name) do
            [{u_name, pass, node_name, login, id, tweet_list, following_list, follower_list}] -> 
                if login == false do
                    if pass == password do
                        :ets.insert(:usertable, {u_name, password, session_Id, true, session_Id, tweet_list, following_list, follower_list})
                        {:ok, "Welcome #{u_name}!!"}    
                    else
                        {:ok, "Invalid Passcode "}                       
                    end
 
                else
                    {:ok, "Welcome Back"}
                end                
            [] -> {:ok, "Invalid credentials"}
        end

    end

#..................... insert tweet.............................................

    def insert_tweet(u_name, tweet) do
        if :ets.lookup(:usertable, u_name) ==[] do
            {:error, "failed to tweet."}
        else
            [{u_name, password, node_name, login_state, session_Id, tweet_list, following_list, follower_list}] = :ets.lookup(:usertable, u_name)
            :ets.insert(:usertable, {u_name, password, node_name, login_state, session_Id, [tweet | tweet_list], following_list, follower_list})
            {:ok, "tweeted"}
        end
    end    
#..................... insert follower.............................................
def insert_follower(followed_u_name, follower_u_name) do 
        x = :ets.lookup(:usertable, followed_u_name)
        if :ets.lookup(:usertable, followed_u_name) ==[] do
            {:error, ""}
        else
            [{u_name, password, node_name, login_state, session_Id, tweet_list, following_list, follower_list}] = :ets.lookup(:usertable, followed_u_name)
            :ets.insert(:usertable, {u_name, password, node_name, login_state, session_Id, tweet_list, following_list, [follower_u_name | follower_list]})
            {:ok, ""}
        end
       
    end    

    #..................... insert following.............................................

    
    def insert_following(followed_u_name, follower_u_name) do   
        if :ets.lookup(:usertable, follower_u_name) == [] do
            {:error, "failed to follow #{followed_u_name}"}
        else
            [{u_name, password, node_name, login_state, session_Id, tweet_list, following_list, follower_list}] = :ets.lookup(:usertable, follower_u_name)
            :ets.insert(:usertable, {u_name, password, node_name, login_state, session_Id, tweet_list, [followed_u_name | following_list], follower_list})
            {:ok, "You are now following #{followed_u_name}"}
        end
   
    end

    def reetwt(node,spid) do
        tweet = :ets.lookup(:tweetable,node)|>List.first()|>Tuple.to_list()|>List.last()|>Enum.random()
        #IO.puts "Node #{node} retweeting #{tweet}"
        GenServer.cast(spid,{:publishtweet,node,tweet})
    end

#..................... get follower............................................

    def get_follower(u_name) do 
        sub_list = :ets.lookup(:usertable,u_name)|>List.first()|>Tuple.to_list()|>List.last()
        if :ets.lookup(:usertable, u_name) == [] do
            {:error, []}
        else
            [{_, _, _, _, _, _, _, follo_list}] = :ets.lookup(:usertable, u_name)
            {:ok, follo_list}
        end
   
    end     
#..................... get following.............................................


    def get_following(u_name) do 
        if :ets.lookup(:usertable, u_name) == [] do
            {:error, []}
        else
            [{_, _, _, _, _, _, follow_list, _}] = :ets.lookup(:usertable, u_name)
            {:ok, follow_list}
        end
   
    end

    def retweet(user) do
        user = Integer.to_string(user)
        if :ets.lookup(:tweetable,user) == [] do
                "User dont exist for retweeting"
        else
                pid = :ets.lookup(:users,user)|>List.first()|>Tuple.to_list()|>List.last()
                tweet = :ets.lookup(:tweetable,user)|>List.first()|>Tuple.to_list()|>List.last()|>Enum.random()
                state = Client.get_state(pid)
                spid = Map.get(state,:spid)
                GenServer.cast(spid,{:publishtweet,user,tweet})
                "User #{user} retweeting {#{tweet}}"
        end
end
    
#..................... storing hashtweets.............................................


    def store_hash(hashtag, tweet) do
        [tag | _] = hashtag
        if :ets.lookup(:hashtags, tag) == [] do
            :ets.insert_new(:hashtags, {tag, [tweet]})
        else
            [{tag, tweet_list}] = :ets.lookup(:hashtags, tag)
            :ets.insert_new(:hashtags, {tag, [tweet]})
        end

    end
#..................... store users.............................................

    def store_user(u_name, tweet) do
        [user | _] = u_name
        if :ets.lookup(:tweetable_table, user) == [] do
            :ets.insert(:tweetable_table, {user, [tweet]})
        else
            [{user, tweet_list}] = :ets.lookup(:tweetable_table, user)
            :ets.insert(:tweetable_table, {user, [tweet | tweet_list]})
        end

    end
#..................... search hash tweet.............................................

    def find_hash(hashtag) do  
        if :ets.lookup(:hashtags, hashtag) == [] do
            "There are no tweets with hashtag #{hashtag}"
        else
            [{hashtag, tweet_list}] = :ets.lookup(:hashtags, hashtag)
            tweet_list
        end      
    end
    
#..................... search user tweet.............................................

    def find_user(u_name) do 
        if :ets.lookup(:tweetable_table, u_name) == [] do
            "Unable to find mention #{u_name}"
        else
            [{u_name, tweet_list}] = :ets.lookup(:tweetable_table, u_name)
            tweet_list
        end
    end    




end