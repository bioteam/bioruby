module Bio
  class SQL
    class Biodatabase < DummyBase
      attr_accessible :name, :authority, :description
      has_many :bioentries, :class_name =>"Bioentry", :foreign_key => "biodatabase_id", :dependent => :destroy
      validates_uniqueness_of :name
    end
    class BioentryDbxref < DummyBase
      attr_accessible :bioentry, :dbxref
      set_primary_key nil #bioentry_id,dbxref_id
      belongs_to :bioentry, :class_name => "Bioentry"
      belongs_to :dbxref, :class_name => "Dbxref"
    end

    class BioentryPath < DummyBase
      attr_accessible :distance, :term, :object_bioentry, :subject_bioentry
      set_primary_key nil
      #delete				set_sequence_name nil
      belongs_to :term, :class_name => "Term"
      #da sistemare per poter procedere.
      belongs_to :object_bioentry, :class_name=>"Bioentry"
      belongs_to :subject_bioentry, :class_name=>"Bioentry"
    end #BioentryPath

    class BioentryQualifierValue < DummyBase
      #NOTE: added rank to primary_keys, now it's finished.
      attr_accessible :value, :rank, :bioentry, :term
      set_primary_keys :bioentry_id, :term_id, :rank
      belongs_to :bioentry, :class_name => "Bioentry"
      belongs_to :term, :class_name => "Term"
    end #BioentryQualifierValue
  
    class Bioentry < DummyBase
      attr_accessible :name, :accession, :identifier, :division, :description, :version, :biodatabase, :taxon
      belongs_to :biodatabase, :class_name => "Biodatabase"
      belongs_to :taxon, :class_name => "Taxon"
      has_one :biosequence, :dependent => :destroy
      #, :class_name => "Biosequence", :foreign_key => "bioentry_id"
      has_many :comments, :class_name =>"Comment", :order =>'rank', :dependent => :destroy
      has_many :seqfeatures, :class_name => "Seqfeature", :order=>'rank', :dependent => :destroy
# no delete
      has_many :bioentry_references, :class_name=>"BioentryReference", :dependent => :destroy #, :foreign_key => "bioentry_id"
      has_many :bioentry_dbxrefs, :class_name => "BioentryDbxref", :dependent => :destroy
      has_many :object_bioentry_relationships, :class_name=>"BioentryRelationship", :foreign_key=>"object_bioentry_id", :dependent => :destroy #non mi convince molto credo non funzioni nel modo corretto
      has_many :subject_bioentry_relationships, :class_name=>"BioentryRelationship", :foreign_key=>"subject_bioentry_id", :dependent => :destroy #non mi convince molto credo non funzioni nel modo corretto
      has_many :object_bioentry_paths, :class_name=>"BioentryPath", :foreign_key=>"object_bioentry_id", :dependent => :destroy #non mi convince molto credo non funzioni nel modo corretto
      has_many :subject_bioentry_paths, :class_name=>"BioentryPath", :foreign_key=>"subject_bioentry_id", :dependent => :destroy #non mi convince molto credo non funzioni nel modo corretto
# no delete
      has_many :cdsfeatures, :class_name=>"Seqfeature", :foreign_key =>"bioentry_id", :conditions=>["term.name='CDS'"], :include=>"type_term"
      has_many :references, :through=>:bioentry_references, :class_name => "Reference", :dependent => :destroy
# no delete
      has_many :terms, :through=>:bioentry_qualifier_values, :class_name => "Term", :dependent => :destroy
      #NOTE: added order_by for multiple hit and manage ranks correctly
      has_many :bioentry_qualifier_values, :order=>"bioentry_id,term_id,rank", :class_name => "BioentryQualifierValue", :dependent => :destroy
        
      #per la creazione richiesti:
      #name, accession, version
      #				validates_uniqueness_of :accession, :scope=>[:biodatabase_id]
      #				validates_uniqueness_of :name, :scope=>[:biodatabase_id]
			#	validates_uniqueness_of :identifier, :scope=>[:biodatabase_id]
				
    end
    class BioentryReference < DummyBase
      attr_accessible :start_pos, :end_pos, :rank, :bioentry, :reference
      set_primary_keys :bioentry_id, :reference_id, :rank
      belongs_to :bioentry, :class_name => "Bioentry"
      belongs_to :reference , :class_name => "Reference"
    end
    class BioentryRelationship < DummyBase
      attr_accessible :rank, :term, :subject_bioentry, :object_bioentry
      #delete				set_primary_key "bioentry_relationship_id"
      set_sequence_name "bieontry_relationship_pk_seq"
      belongs_to :object_bioentry, :class_name => "Bioentry"
      belongs_to :subject_bioentry, :class_name => "Bioentry"
      belongs_to :term
    end
    class Biosequence < DummyBase
      attr_accessible :version, :length, :alphabet, :seq
      set_primary_keys :bioentry_id, :version
      #delete				set_sequence_name "biosequence_pk_seq"
      belongs_to :bioentry, :foreign_key=>"bioentry_id"
      #has_one :bioentry
      #, :class_name => "Bioentry"
    end
    class Comment < DummyBase
      attr_accessible :comment_text, :rank, :bioentry
      belongs_to :bioentry, :class_name => "Bioentry"
    end
    class DbxrefQualifierValue < DummyBase
      attr_accessible :rank, :value, :term, :dbxref
      #think to use composite primary key
      set_primary_key nil #dbxref_id, term_id, rank
      #delete			      set_sequence_name nil
      belongs_to :dbxref, :class_name => "Dbxref"
      belongs_to :term, :class_name => "Term"
    end
    class Dbxref < DummyBase
      attr_accessible :dbname, :accession, :version
      #set_sequence_name "dbxref_pk_seq"
      has_many :dbxref_qualifier_values, :class_name => "DbxrefQualifierValue", :dependent => :destroy
      has_many :locations, :class_name => "Location", :dependent => :destroy
      has_many :references, :class_name=>"Reference", :dependent => :destroy
      has_many :term_dbxrefs, :class_name => "TermDbxref", :dependent => :destroy
      has_many :bioentry_dbxrefs, :class_name => "BioentryDbxref", :dependent => :destroy
      #TODO: check is with bioentry there is an has_and_belongs_to_many relationship has specified in schema overview.
    end
    class LocationQualifierValue <  DummyBase
      attr_accessible :value, :int_value, :location, :term
      set_primary_key nil #location_id, term_id
      #delete			      set_sequence_name nil
      belongs_to :location, :class_name => "Location"
      belongs_to :term, :class_name => "Term"
    end
    class Location < DummyBase
      attr_accessible :start_pos, :end_pos, :strand, :rank, :seqfeature, :dbxref, :term
      #set_sequence_name "location_pk_seq"
      belongs_to :seqfeature, :class_name => "Seqfeature"
      belongs_to :dbxref, :class_name => "Dbxref"
      belongs_to :term, :class_name => "Term"
      has_many :location_qualifier_values, :class_name => "LocationQualifierValue", :dependent => :destroy
      
      def to_s
        if strand==-1
          str="complement("+start_pos.to_s+".."+end_pos.to_s+")"
        else
          str=start_pos.to_s+".."+end_pos.to_s
        end
        return str    
      end
      
      def sequence
        seq=""
        unless self.seqfeature.bioentry.biosequence.seq.nil?
          seq=Bio::Sequence::NA.new(self.seqfeature.bioentry.biosequence.seq[start_pos-1..end_pos-1])
          seq.reverse_complement! if strand==-1
        end
        return seq        
      end
      
      
      
    end
    class Ontology < DummyBase
      attr_accessible :name, :definition
      has_many :terms, :class_name => "Term", :dependent => :destroy
      has_many :term_paths, :class_name => "TermPath", :dependent => :destroy
      has_many :term_relationships, :class_name => "TermRelationship", :dependent => :destroy
    end
    class Reference < DummyBase
      attr_accessible :location, :title, :authors, :crc, :dbxref
      belongs_to :dbxref, :class_name => "Dbxref"
      has_many :bioentry_references, :class_name=>"BioentryReference", :dependent => :destroy
# no delete
      has_many :bioentries, :through=>:bioentry_references
    end
    class SeqfeatureDbxref < DummyBase
      attr_accessible :rank, :seqfeature, :dbxref
      set_primary_keys :seqfeature_id, :dbxref_id
      #delete		      set_sequence_name nil
      belongs_to :seqfeature, :class_name => "Seqfeature", :foreign_key => "seqfeature_id"
      belongs_to :dbxref, :class_name => "Dbxref", :foreign_key => "dbxref_id"
    end
    class SeqfeaturePath < DummyBase
      attr_accessible :distance, :term, :subject_seqfeature, :object_seqfeature
      set_primary_keys :object_seqfeature_id, :subject_seqfeature_id, :term_id
      set_sequence_name nil
      belongs_to :object_seqfeature, :class_name => "Seqfeature", :foreign_key => "object_seqfeature_id"
      belongs_to :subject_seqfeature, :class_name => "Seqfeature", :foreign_key => "subject_seqfeature_id"
      belongs_to :term, :class_name => "Term"
    end
    class SeqfeatureQualifierValue < DummyBase
      attr_accessible :rank, :value, :term, :seqfeature
      set_primary_keys  :seqfeature_id, :term_id, :rank
      set_sequence_name nil
      belongs_to :seqfeature
      belongs_to :term, :class_name => "Term"
    end		
    class Seqfeature <DummyBase  
      attr_accessible :display_name, :rank, :source_term, :type_term, :bioentry
      set_sequence_name "seqfeature_pk_seq"
      belongs_to :bioentry
      #, :class_name => "Bioentry"
      belongs_to :type_term, :class_name => "Term", :foreign_key => "type_term_id"
      belongs_to :source_term, :class_name => "Term", :foreign_key =>"source_term_id"
      has_many :seqfeature_dbxrefs, :class_name => "SeqfeatureDbxref", :foreign_key => "seqfeature_id", :dependent => :destroy
      has_many :seqfeature_qualifier_values, :order=>'rank', :foreign_key => "seqfeature_id", :dependent => :destroy
      #, :class_name => "SeqfeatureQualifierValue"
      has_many :locations, :class_name => "Location", :order=>'rank', :dependent => :destroy
      has_many :object_seqfeature_paths, :class_name => "SeqfeaturePath", :foreign_key => "object_seqfeature_id", :dependent => :destroy
      has_many :subject_seqfeature_paths, :class_name => "SeqfeaturePath", :foreign_key => "subject_seqfeature_id", :dependent => :destroy
      has_many :object_seqfeature_relationships, :class_name => "SeqfeatureRelationship", :foreign_key => "object_seqfeature_id", :dependent => :destroy
      has_many :subject_seqfeature_relationships, :class_name => "SeqfeatureRelationship", :foreign_key => "subject_seqfeature_id", :dependent => :destroy

      #get the subsequence described by the locations objects
      def sequence
        return self.locations.inject(Bio::Sequence::NA.new("")){|seq, location| seq<<location.sequence}
      end
    
      #translate the subsequences represented by the feature and its locations
      #not considering the qualifiers 
      #Return a Bio::Sequence::AA object
      def translate(*args)
        self.sequence.translate(*args)
      end
    end
    class SeqfeatureRelationship <DummyBase
      attr_accessible :rank, :term, :object_seqfeature, :subject_seqfeature
      set_sequence_name "seqfeatue_relationship_pk_seq"
      belongs_to :term, :class_name => "Term"
      belongs_to :object_seqfeature, :class_name => "Seqfeature"
      belongs_to :subject_seqfeature, :class_name => "Seqfeature"
    end
    class TaxonName < DummyBase
      attr_accessible :name, :name_class, :taxon
      set_primary_keys :taxon_id, :name, :name_class
      belongs_to :taxon, :class_name => "Taxon"
    end
    class Taxon < DummyBase
      attr_accessible :ncbi_taxon_id, :parent_taxon_id, :node_rank, :genetic_code, :mito_genetic_code, :left_value, :right_value
      set_sequence_name "taxon_pk_seq"
      has_many :taxon_names, :class_name => "TaxonName", :dependent => :destroy
# no delete
      has_one :taxon_scientific_name, :class_name => "TaxonName", :conditions=>"name_class = 'scientific name'"
# no delete
      has_one :taxon_genbank_common_name, :class_name => "TaxonName", :conditions=>"name_class = 'genbank common name'"
      has_one :bioentry, :class_name => "Bioentry", :dependent => :destroy
    end
    class TermDbxref < DummyBase
      attr_accessible :rank, :term, :dbxref
      set_primary_key nil #term_id, dbxref_id
      #delete			      set_sequence_name nil
      belongs_to :term, :class_name => "Term"
      belongs_to :dbxref, :class_name => "Dbxref"
    end
    class TermPath < DummyBase
      attr_accessible :distance, :ontology, :subject_term, :object_term, :predicate_term
      set_sequence_name "term_path_pk_seq"
      belongs_to :ontology, :class_name => "Ontology"
      belongs_to :subject_term, :class_name => "Term"
      belongs_to :object_term, :class_name => "Term"
      belongs_to :predicate_term, :class_name => "Term"
    end
    class Term < DummyBase
      attr_accessible :name, :definition, :identifier, :is_obsolete, :ontology
      belongs_to :ontology, :class_name => "Ontology"
      has_many :seqfeature_qualifier_values, :class_name => "SeqfeatureQualifierValue", :dependent => :destroy
      has_many :dbxref_qualifier_values, :class_name => "DbxrefQualifierValue", :dependent => :destroy
      has_many :bioentry_qualifer_values, :class_name => "BioentryQualifierValue", :dependent => :destroy
# no delete
      has_many :bioentries, :through=>:bioentry_qualifier_values
      has_many :locations, :class_name => "Location", :dependent => :destroy
      has_many :seqfeature_relationships, :class_name => "SeqfeatureRelationship", :dependent => :destroy
      has_many :term_dbxrefs, :class_name => "TermDbxref", :dependent => :destroy
      has_many :term_relationship_terms, :class_name => "TermRelationshipTerm", :dependent => :destroy
      has_many :term_synonyms, :class_name => "TermSynonym", :dependent => :destroy
      has_many :location_qualifier_values, :class_name => "LocationQualifierValue", :dependent => :destroy
      has_many :seqfeature_types, :class_name => "Seqfeature", :foreign_key => "type_term_id", :dependent => :destroy
      has_many :seqfeature_sources, :class_name => "Seqfeature", :foreign_key => "source_term_id", :dependent => :destroy
      has_many :term_path_subjects, :class_name => "TermPath", :foreign_key => "subject_term_id", :dependent => :destroy
      has_many :term_path_predicates, :class_name => "TermPath", :foreign_key => "predicate_term_id", :dependent => :destroy
      has_many :term_path_objects, :class_name => "TermPath", :foreign_key => "object_term_id", :dependent => :destroy
      has_many :term_relationship_subjects, :class_name => "TermRelationship", :foreign_key =>"subject_term_id", :dependent => :destroy
      has_many :term_relationship_predicates, :class_name => "TermRelationship", :foreign_key =>"predicate_term_id", :dependent => :destroy
      has_many :term_relationship_objects, :class_name => "TermRelationship", :foreign_key =>"object_term_id", :dependent => :destroy
      has_many :seqfeature_paths, :class_name => "SeqfeaturePath", :dependent => :destroy
    end
    class TermRelationship < DummyBase
      attr_accessible :ontology, :subject_term, :predicate_term, :object_term
      set_sequence_name "term_relationship_pk_seq"
      belongs_to :ontology, :class_name => "Ontology"
      belongs_to :subject_term, :class_name => "Term"
      belongs_to :predicate_term, :class_name => "Term"
      belongs_to :object_term, :class_name => "Term"
      has_one :term_relationship_term, :class_name => "TermRelationshipTerm", :dependent => :destroy
    end
    class TermRelationshipTerm < DummyBase
      attr_accessible :term_relationship, :term
      #delete			      set_sequence_name nil
      set_primary_key :term_relationship_id
      belongs_to :term_relationship, :class_name => "TermRelationship"
      belongs_to :term, :class_name => "Term"
    end
    class TermSynonym < DummyBase
      #delete			      set_sequence_name nil
      attr_accessible :synonym, :term
      set_primary_key nil
      belongs_to :term, :class_name => "Term"
    end
  end #SQL
end #Bio
