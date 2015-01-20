require 'sparql/client'
class SparqlQuick
  
  attr_reader :_query
  attr_reader :_update
  
  # _endpoint { String }
  # _prefixes { Hash }
  
  def initialize( _endpoint, _prefixes=nil )
    @endpoint = _endpoint
    @prefixes = _prefixes
    
    #  Grab query and update handles
    
    @_query = handle( 'query' )
    @_update = handle( 'update' )
  end
  
  
  # Insert a single triple
  # _triple { Array }
  
  def insert( _triple )
    triple = uris( _triple )
    
    #  Insert the data
    
    @_update.insert_data( graph( triple ) )
  end
  
  
  # Update a single triple
  # _triple { Array }
  
  def update( _triple )
    toDelete = _triple.clone
    toDelete[2] = :o
    results = select( toDelete )
    if results.length > 1
      raise "Can only update one triple at a time.  Multiple triples returned during check"
    end
    delete( toDelete )
    insert( _triple )
  end
  
  
  # Delete a triple or partial triple
  # _triple { Array }
  
  def delete( _triple )
    
    #  Safety check
    
    check_count = 0
    _triple.each do | check |
      if check.class == ::Symbol
        check_count += 1
      end
    end
    if check_count == 0
      destroy( _triple )
      return
    end
    if check_count == 3
      raise "Did you really want to delete entire database? Argument must contain one URI or literal value."
    end
    
    #  Check to see what you're deleting
    
    results = select( _triple )
    
    #  SPARQL::Client.delete_data can only delete a complete
    #  s,p,o triple.  So we have to fill in the details.
    
    results.each do | hash |
      toDelete = _triple.clone
      hash.keys.each do | key |
        case key
          when :s
            toDelete[0] = hash[key].to_s.tagify
          when :p
            toDelete[1] = hash[key].to_s.tagify
          when :o
            toDelete[2] = hash[key]
            if toDelete[2].class == RDF::URI
              toDelete[2] = toDelete[2].to_s.tagify
            end
        end
      end
      
      destroy( toDelete )
    end
  end
  
  
  # _triple { Array }
  # @return { Array }
  
  def select( _triple )
    triple = uris( _triple )
    
    #  Grab a SPARQL handle and run the query
    
    query = @_query.select.where( triple )
    
    #  Build the results object
    
    results=[]
    query.each_solution.each do | val |
      results.push( val.bindings )
    end
    results
  end
  
  
  # _double { Array }
  # @return { Array, String }
  
  def value( _double )
    results = get_objects( _double )
    if results.length == 0
      return nil
    end
    
    #  Get the values
    
    out = []
    results.each do | val |
      out.push( val[:o].to_s )
    end
    
    #  If only a single value is returned don't return
    #  an array with one element in it.
    
    if out.length == 1
      return out[0]
    end
    
    #  Return an array
    
    return out
  end
  
  
  # _double { Array }
  # @return { Fixnum }
  
  def count( _triple )
    select( _triple ).length
  end
  
  
  # _type { String }
  # @return { SPARQL::Client }
  
  def handle( _type )
    SPARQL::Client.new( File.join( @endpoint, _type ) )
  end
  
  
  # _double { Array }
  # _side { Symbol }
  
  def indexed_urns( _double, _side )
    case _side
      when :o then get_objects( _double )
      when :s then get_subjects( _double )
    end
  end

  # Get the next index
  # _double { Array }
  # _side { Symbol }
  # @return { Integer }
  
  def next_index( _double, _side=:o )
    
    #  Where's the indexed URNs?
    
    results = indexed_urns( _double, _side )
    return 1 if results.empty?
    ns = []
    results.each do | val |
      ns.push( urn_index( val[ _side ] ) )
    end
    ns.max + 1
  end
  
  # Take a URN and return just the index if it exists
  # _urn { RDF::URI }
  # @return { Integer }
  
  def urn_index( _urn )
    _urn.to_s.gsub(/\d+$/).next.to_i
  end
  
  # Build URIs
  # _triple { Array }
  # @return { Array }
   
  def uris( _triple )
    triple=[]
    _triple.each do | val |
      triple.push( uri( val ) )
    end
    triple
  end
  
  
  # _val { String, Symbol, etc... }
  # _return { RDF::URI, RDF::Literal, Symbol }
  
  def uri( _val )
    
    #  If it's a symbol get out of there.
    
    if _val.class == ::Symbol
      return _val
    end
    
    #  Are you a URI or a literal?
    
    if _val.class == ::String
      
      #  URI with no prefix
      
      first = _val[0]
      last = _val[-1,1]
      if first == "<" && last == ">"
        return RDF::URI( _val.clip )
      end
      
      #  With prefix
      
      unless @prefixes == nil
        pre, colon, last = _val.rpartition(':')
        pre = pre.to_sym
        if @prefixes.has_key?( pre )
          return uri( "<#{@prefixes[ pre ].clip}#{last}>" )
        end
      end
    end
    RDF::Literal( _val )
  end
  
  
  # Empty the entire database
  # _verify { String }
  
  def empty( _verify=nil )
    keyword = :all
    unless _verify == keyword
      raise "If you really want to empty the database run empty( :#{ keyword } )"
    end
    @_update.clear( :all )
  end
  
  
  # _double { Array }
  # @return { Array }
  
  def get_objects( _double )
    triple = _double.clone
    triple[2] = :o
    select( triple )
  end
  
  
  # _double { Array }
  # @return { Array }
  
  def get_subjects( _double )
    triple = _double.clone
    triple.unshift( :s )
    select( triple )
  end
  
  
  # Remove a triple for real...
  # _triple { Array }
  
  def destroy( _triple )
    triple = uris( _triple )
    @_update.delete_data( graph( triple ) )
  end
  
  
  # Build a RDF::Graph triple
  # _triple { Array }
  # @return { RDF::Graph }
  
  def graph( _triple )
    RDF::Graph.new { | graph |
      graph << _triple
    }
  end
  
end



class String
  
  
  # Clip the first and last characters from a string
  # @return { String }
  
  def clip
    self[1..-2]
  end
  
  
  # Check to see if we're looking at an integer in string's clothing
  
  def is_i?
     !!( self =~ /\A[-+]?[0-9]+\z/ )
  end
  
  
  # Return integer
  
  def just_i
    /\d+/.match( self ).to_s.to_i
  end
  
  
  # Wrap <>
  
  def tagify
    this = self
    if this[0] != "<"
      this = "<#{this}"
    end
    if this[-1,1] != ">"
      this = "#{this}>"
    end
    this
  end
  
end