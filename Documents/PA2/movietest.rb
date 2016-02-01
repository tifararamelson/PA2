class MovieTest

	# Constructor for MovieTest object, takes an array of hashes in the form of: u, m, r, p
	def initialize(arr)
		@result = arr
	end

	# Gets the average prediction error
	def mean
		mean = 0
		@result.each do |x|
			mean += (x[:r] - x[:p]).abs.to_f / x[:p].to_f
		end
		puts "The average prediction error is: #{mean / @result.length}"
	end

	# Gets the standard deviation of error
	def stddev
		sd = 0
		@result.each do |x|
			sd += ((x[:r] - x[:p]) ** 2) / (x[:p].to_f - @result.length)
		end
		sed = sd / Math.sqrt(@result.length)
		puts "The standard deviation of error is: #{sed}"
	end

	# Gets the root mean square error of the prediction
	def rms
		squares = 0
		@result.each do |x|
			squares += (x[:r] - x[:p]) ** 2
		end
		puts "The root mean square is: #{Math.sqrt(squares / @result.length)}"
	end

	# Prints the array of the predictions in the form [u,m,r,p]
	def to_a
		@result.each do |x|
			puts "#{x[:u]} #{x[:m]} #{x[:r]} #{x[:p]}"
		end
	end
end