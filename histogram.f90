program histogram
        
        implicit none
        real, allocatable :: PE(:)
        integer, allocatable :: hist(:)
        real :: min_v, max_v, bin_width
        character(len=10) :: arg
        integer :: n, n_bins=100, i, j, k
        call get_command_argument(1, arg)
        read(arg, '(i10)') n
        allocate(PE(n))
        allocate(hist(n_bins))
        
        open(10, file="histogram.dat")
        open(11, file="pp+0.5pw.txt")
        read(11, *) PE


        min_v=minval(PE)
        max_v=maxval(PE)
        bin_width=(max_v-min_v)/real(n_bins)

        hist=0
        do i=1, n_bins
            do j=1, n
                if (PE(j)>(min_v+(real(i)-1.0)*bin_width) .and. PE(j)<=(min_v+real(i)*bin_width)) then
                    hist(i)=hist(i)+1
                end if
            end do
         end do

        do k=1, n_bins
            write(10, *) min_v+k*bin_width, hist(k)
        end do 
end program
