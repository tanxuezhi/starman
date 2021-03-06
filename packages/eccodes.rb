class Eccodes < Package
  url 'https://confluence.ecmwf.int/download/attachments/45757960/eccodes-2.10.0-Source.tar.gz?api=v2'
  sha256 'bea3cb4caafca368538bc457075bbe848215085f3574cfcdf106d32e954d82d8'

  depends_on :cmake
  depends_on :openjpeg
  depends_on :jasper
  depends_on :netcdf

  option 'with-python2', 'Build Python 2 bindings.'
  option 'with-python3', 'Build Python 3 bindings.'

  def export_env
    append_env 'PYTHONPATH', "#{Dir.glob(lib + '/python*').first}/site-packages"
  end

  def install
    inreplace 'cmake/FindOpenJPEG.cmake', {
      'include/openjpeg-2.1 )' => "include/openjpeg-2.1 include/openjpeg-#{Openjpeg.version.major_minor} )"
    }
    args = std_cmake_args search_paths: [link_root]
    args << '-DENABLE_JPG=On'
    args << '-DENABLE_NETCDF=On'
    args << '-DENABLE_FORTRAN=On'
    args << "-DOPENJPEG_PATH='#{link_root}'"
    args << "-DJASPER_PATH='#{link_root}'"
    args << "-DNETCDF_PATH='#{link_root}'"
    if with_python3?
      args << "-DENABLE_PYTHON=On"
      args << "-DPYTHON_EXECUTABLE=#{which 'python3'}"
      CLI.warning "Ignore #{CLI.red '--with-python2'} option." if with_python2?
    elsif with_python2?
      args << "-DENABLE_PYTHON=On"
    end
    mkdir 'build' do
      run 'cmake', '..', *args
      run 'make'
      run 'make', 'check' unless skip_test?
      run 'make', 'install'
    end
  end
end
