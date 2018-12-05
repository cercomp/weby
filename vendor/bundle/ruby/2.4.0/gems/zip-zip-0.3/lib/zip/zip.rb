require 'zip'

Zip::Zip                     =  Zip
Zip::ZipCentralDirectory     =  Zip::CentralDirectory
Zip::ZipEntry                =  Zip::Entry
Zip::ZipEntrySet             =  Zip::EntrySet
Zip::ZipExtraField           =  Zip::ExtraField
Zip::ZipFile                 =  Zip::File
Zip::ZipInputStream          =  Zip::InputStream
Zip::ZipOutputStream         =  Zip::OutputStream
Zip::ZipStreamableDirectory  =  Zip::StreamableDirectory
Zip::ZipStreamableStream     =  Zip::StreamableStream
IOExtras                     =  Zip::IOExtras

module Zip
  class Entry
    alias :is_directory :directory?
    alias :localHeaderOffset :local_header_offset
  end

  class ExtraField
    alias :local_length :local_size
    alias :c_dir_length :c_dir_size
  end

  module OptionsAdapter
    def self.[]=(key, value)
      Zip.send("#{key}=", value)
    end

    def self.[](key)
      Zip.send(key)
    end
  end

  def options
    OptionsAdapter
  end
end
