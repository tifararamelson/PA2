require './movietest.rb'

class MovieData

	# Constructor for MovieData object, takes a u.data file or a file in that format, optionally takes another file in the same format
	def initialize(path, test = nil)
		@train_u_i_r = Hash.new
		@train_u_i = Hash.new
		@train_i_u = Hash.new
		@train_users = Array.new
		@test_u_i_r = Hash.new
		@test_user_m = Array.new

		#check if the optional parameter was specified
		if test == nil #call load_data for 100% of path
			load_data(path, 100000)
		else #otherwise call load_data for 80% of path, 20% of test
			load_data(path, 100000, test, 80000)
		end
	end

	# Stores the data in the instance variables
	def load_data(path, p_lines, test=nil, t_lines=nil)
		if test != nil #call on a different method from here
			extract_data(test, t_lines)
			@test_user_m, @test_u_i_r, @test_u_i, @test_i_u = extract_data(test, t_lines)
		end
		@train_users_r, @train_u_i_r, @train_u_i, @train_i_u = extract_data(path, p_lines)

	end

	# Parses the text and stores the info in various data structures
	def extract_data(path, num_lines)
		count = 1
		item_rating = Hash.new{|key, value| key[value] = []}
		user_item_rating = Hash.new{|key, value| key[value] = []}
		user_items = Hash.new{|key, value| key[value] = []}
		item_users = Hash.new{|key, value| key[value] = []}
		user_movie = Array.new
		open(path).each do |line| 
			if count == num_lines
				break
			end
			result = line.split(/\t/)
			user_rating = {u: result[0].to_i, m: result[1].to_i}
			user_movie.push(user_rating)
			item_rating[result[1].to_i].push(result[2].to_i) #need to convert to int
			item_r_temp = Hash.new
			item_r_temp[result[1].to_i] = result[2].to_i 
			user_item_rating[result[0].to_i].push(item_r_temp)
			user_items[result[0].to_i].push(result[1].to_i)
			item_users[result[1].to_i].push(result[0].to_i)
			count += 1
		end
		return user_movie, user_item_rating, user_items, item_users
	end

	# Gets the rating that user u rated movie m, 0 if user did not rate that movie
	def rating(u, m)
		@train_u_i_r[u].each do |x|
			x.each do |i, r|
				if i == m
					return r
				end	
			end
		end
		return 0
	end

	# Estimates user u's rating of movie m
	def predict(u, m)
		rating = rating(u, m)
		if rating == 0 #if the user didn't rate the movie
			users = viewers(m)
			user = most_similar(u, users)
			@train_u_i_r[user].each do |x|
				x.each do |i, r|
					if i == m
						return r.to_f
					end
				end
			end
		else #if user already rated the movie
			return rating.to_f
		end
	end

	# Gets the user that is most similar to user u from a list of users
	def most_similar(u, users)
		score = -1
		user = -1
		users.each do |u2|
			if u != u2 #ensure it's not the same user
				sim = similarity(u, u2) 
				if sim > score #new score if similarity is higher
					score = sim
					user = u2
				end
			end
		end
		return user
	end

	# Calculates how similar user u1 is to user u2
	def similarity(u1, u2)
		#Stores the info for each user
		u1_ratings = {}
		@train_u_i_r[u1].each do |h|
			h.each do |m, r|
				u1_ratings[m] = r
			end
		end
		u2_ratings = {}
		@train_u_i_r[u2].each do |h|
			h.each do |m, r|
				u2_ratings[m] = r
			end
		end

		#Calculates the similarity between the 2 users
		count = 0 #to get num of movies they both rated
		pts = 0.0 #overall score

		#for each item - if they both rated it, assigns points based on how similar users are
		@train_u_i_r.each do |item, ratings|
			if (u1_ratings.include? item) && (u2_ratings.include? item)
				count += 1
				case (u1_ratings[item] - u2_ratings[item]).abs
				when 0
					pts += 5.0
				when 1
					pts += 4.0
				when 2
					pts += 3.0
				when 3
					pts += 2.0
				when 4
					pts += 1.0
				else #5
					pts += 0.0
				end
			end
		end
		total = pts/(count*5.0)
		return total
	end

	# Gets the all the movies that user u rated
	def movies(u)
		 return @train_u_i[u]
	end

	# Gets all the users that rated movie m
	def viewers(m)
		return @train_i_u[m]
	end

	#runs z.predict on the first k ratings and returns a MovieTest object containing the results
	#k is optional - all tests will be run if omitted
	def run_test(k = nil)
		count = 1
		arr = Array.new
		@test_user_m.each do |x|
			u = x[:u]
			m = x[:m]
			rating = 0.0
		 	@test_u_i_r[u].each do |y|
		 		y.each do |mov, rat|
		 			if mov == m
		 				rating = rat.to_f
		 				break
		 			end
		 		end
		 	end

		 	pred = predict(u, m) #prediction

		 	arr.push(u: u, m: m, r: rating, p: pred)
		 	#puts arr

		 	if count == k #if k is specified
		 		break
		 	end
		 	count += 1
		end

		mt = MovieTest.new(arr)
		mt.mean
		mt.stddev
		mt.rms
	end
end

m = MovieData.new('ml-100k/u.data', 'ml-100k/u1.base')#('ml-100k/u.data', 'ml-100k/u1.test')
#Tests
#puts m.rating(13, 8)
#puts m.rating(920, 347)
#puts m.movies(1)
#puts m.viewers(236)
#puts "\n\n"
#puts m.rating(234, 24)
#puts m.rating(13, 8)
#puts m.rating(1, 1)
#m.predict(1, 1)
#m.predict(234, 24)

#Running the tests
puts Time.now
m.run_test()
puts Time.now
