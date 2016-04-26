require 'pg'
require 'rest-client'
require 'json'

class WelcomeController < ActionController::Base
	def index
	end
	def connect
		@conn = PG.connect(
			:dbname => "emptyapp_development",
			:user => "radhikaprad",
			:password => "")
		
	end

	def disconnect
		@conn.close
	end

	def everyrowindb(rowid)
		connect
		puts "hello"
		result=@conn.exec("SELECT count(govid) FROM govcensus")
		puts "bye"

		for i in result
			puts i['count']
			if i['count']== "0"
				puts i['count']
				readjson
			
		#populate the database
			
			end
		end

		begin
			allrowsresult = @conn.exec("SELECT * FROM govcensus where id=#{rowid}")
		rescue Exception=> e
			puts e.message
			puts e.backtrace.inspect
		ensure
			disconnect
		end
		return allrowsresult
	end

	def readjson
		url = 'http://api.census.gov/data/2014/acs1/variables.json'
		response = RestClient.get(url)
		parsedjson = JSON.parse(response)
		firstkey = parsedjson.keys[0]
		mainkeyvalues = parsedjson[firstkey]
		mainkeysarray = mainkeyvalues.keys
		for i in 2..102 # we are interested in 100 rows only for this project
			mainkey = mainkeysarray[i]
			innerkeyvalues = mainkeyvalues[mainkeysarray[i]]
			innerkeysarray = innerkeyvalues.keys
			label = innerkeyvalues[innerkeysarray[0]]
			concept = innerkeyvalues[innerkeysarray[1]]
			predicate= innerkeyvalues[innerkeysarray[2]]
			labelsubstring = label[0..15]
			conceptsubstring= concept[0..15]
			#@conn.exec("insert into govcensus values (#{i},'#{mainkey}','#{labelsubstring}','#{conceptsubstring}','#{innerkeyvalues[innerkeysarray[2]]}')")
			dataupdate=govcensus.create(id:i,govid:mainkey,label:labelsubstring,concept:conceptsubstring,predicatetype:innerkeyvalues[innerkeysarray[2]])
      		dataupdate.save!
		end
	end

	def tabledata
		rowid = params[:i]
		retrievedrow = everyrowindb(rowid)
		retrievedrowjson = retrievedrow.to_json
		#render :json => retrievedrow.to_json
	 	puts retrievedrowjson
		respond_to do |format|
			format.json {render :json => retrievedrow }

			#format.json {retrievedrowjson}
    	end
	end
end
