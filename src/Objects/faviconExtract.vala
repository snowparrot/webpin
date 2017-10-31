
// purpose of class is the extraction of favicons from a webApp
class faviconExtract : Object {
    string[] FAVICON_STRINGS = {"icon", "shortcut icon", "apple-touch-icon-precomposed", "msapplication-TileImage", }; // all resources names linked to favicons in a HTML document  
    protected string HTML_content;
    
    public Gee.List<string> favicons_location;
    
    public faviconExtract (string HTML_content) {
        this.HTML_content = HTML_content;
        
        favicons_location = new Gee.ArrayList<string> ();
        var HTML_content_length = HTML_content.length;
        
        // finds all locations of favicons mentionend in the HTML document
        foreach (string favicon_string in FAVICON_STRINGS){
            var i = 0;
            
            
            /*
            typical example of favicon location is <link rel="shortcut icon" href="//cdn.sstatic.net/stackoverflow/img/favicon.ico?v=4f32ecc8f43d">
            we will search rel="shortcut icon", then href and then extract the location
            */
            while (i < HTML_content_length) {
                // Fehler entsteht durch, dass nicht vorhanden ist.
                var favicon_position = HTML_content.index_of ("rel=\"" + favicon_string + "\"", i);
                var ref_position = HTML_content.index_of ("ref=\"", favicon_position); 
                
                if (favicon_position == -1 || ref_position == -1) {break;} // if we dont find anything its worthless to search with favicon_string
                
                
                // in HTML its very likely that href=" comes before >. If not, we just ignore it
                if (ref_position < HTML_content.index_of (">", favicon_position)) {
                    var quotation_mark = HTML_content.index_of ("\"", ref_position + 5); // 5 is the length of href="
                    if (quotation_mark == -1) {break;} 
                    
                    var extracted_string = HTML_content.slice (ref_position + 5, quotation_mark);
                    
                    favicons_location.add (extracted_string);
                }e
                i = favicon_position + 1; // + 1 prevents infinitive loop              
            }  
        }
    }
    
    
    construct {
        
    } 
}
