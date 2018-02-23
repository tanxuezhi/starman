class NetcdfC < Package
  url 'ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-4.6.0.tar.gz'
  mirror 'https://www.gfd-dennou.org/library/netcdf/unidata-mirror/cdf-4.6.0.tar.gz'
  sha256 '4bf05818c1d858224942ae39bfd9c4f1330abec57f04f58b9c3c152065ab3825'

  grouped_by :netcdf

  depends_on :hdf5

  option 'disable-netcdf-4', 'Disable NetCDF4 interfaces.'

  def install
  	args = %W[
      --prefix=#{prefix}
      --enable-utilities
      --enable-shared
      --enable-static
      --disable-dap-remote-tests
      --disable-doxygen
      --disable-dap
      CPPFLAGS='-I#{link_include}'
      LDFLAGS='-L#{link_lib}'
    ]
    args << '--disable-netcdf-4' if disable_netcdf_4?
    run './configure', *args
    run 'make'
    run 'make', 'check' unless skip_test?
    run 'make', 'install'
  end
end
