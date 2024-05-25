! -
!
! SPDX-FileCopyrightText: Copyright (c) 2017-2022 Pedro Costa and the CaNS contributors. All rights reserved.
! SPDX-License-Identifier: MIT
!
! -
module mod_post
  use mod_precision
  implicit none
  private
  public vorticity,vorticity_one_component,rotation_rate,strain_rate,q_criterion
  contains
  subroutine vorticity(n,dli,dzci,ux,uy,uz,vox,voy,voz)
    !
    ! computes the vorticity field
    !
    implicit none
    integer , intent(in ), dimension(3)        :: n
    real(rp), intent(in ), dimension(3)        :: dli
    real(rp), intent(in ), dimension(0:)       :: dzci
    real(rp), intent(in ), dimension(0:,0:,0:) :: ux ,uy ,uz
    real(rp), intent(out), dimension( :, :, :) :: vox,voy,voz
    real(rp) :: dxi,dyi
    integer :: i,j,k
    dxi = dli(1)
    dyi = dli(2)
    !$acc wait
    !$acc parallel loop collapse(3) default(present)
    !$OMP PARALLEL DO   COLLAPSE(3) DEFAULT(shared)
    do k=1,n(3)
      do j=1,n(2)
        do i=1,n(1)
          !
          ! x component of the vorticity at cell center
          !
          vox(i,j,k) = 0.25_rp*( &
                                (uz(i,j+1,k  )-uz(i,j  ,k  ))*dyi - (uy(i,j  ,k+1)-uy(i,j  ,k  ))*dzci(k  ) + &
                                (uz(i,j+1,k-1)-uz(i,j  ,k-1))*dyi - (uy(i,j  ,k  )-uy(i,j  ,k-1))*dzci(k-1) + &
                                (uz(i,j  ,k  )-uz(i,j-1,k  ))*dyi - (uy(i,j-1,k+1)-uy(i,j-1,k  ))*dzci(k  ) + &
                                (uz(i,j  ,k-1)-uz(i,j-1,k-1))*dyi - (uy(i,j-1,k  )-uy(i,j-1,k-1))*dzci(k-1) &
                               )
          !
          ! y component of the vorticity at cell center
          !
          voy(i,j,k) = 0.25_rp*( &
                                (ux(i  ,j,k+1)-ux(i  ,j,k  ))*dzci(k  ) - (uz(i+1,j,k  )-uz(i  ,j,k  ))*dxi + &
                                (ux(i  ,j,k  )-ux(i  ,j,k-1))*dzci(k-1) - (uz(i+1,j,k-1)-uz(i  ,j,k-1))*dxi + &
                                (ux(i-1,j,k+1)-ux(i-1,j,k  ))*dzci(k  ) - (uz(i  ,j,k  )-uz(i-1,j,k  ))*dxi + &
                                (ux(i-1,j,k  )-ux(i-1,j,k-1))*dzci(k-1) - (uz(i  ,j,k-1)-uz(i-1,j,k-1))*dxi &
                               )
          !
          ! z component of the vorticity at cell center
          !
          voz(i,j,k) = 0.25_rp*( &
                                (uy(i+1,j  ,k)-uy(i  ,j  ,k))*dxi - (ux(i  ,j+1,k)-ux(i  ,j  ,k))*dyi + &
                                (uy(i+1,j-1,k)-uy(i  ,j-1,k))*dxi - (ux(i  ,j  ,k)-ux(i  ,j-1,k))*dyi + &
                                (uy(i  ,j  ,k)-uy(i-1,j  ,k))*dxi - (ux(i-1,j+1,k)-ux(i-1,j  ,k))*dyi + &
                                (uy(i  ,j-1,k)-uy(i-1,j-1,k))*dxi - (ux(i-1,j  ,k)-ux(i-1,j-1,k))*dyi &
                               )
        end do
      end do
    end do
    !$acc wait
  end subroutine vorticity
  !
  subroutine vorticity_one_component(idir,n,dli,dzci,ux,uy,uz,vo)
    !
    ! computes the vorticity field
    !
    implicit none
    integer , intent(in )                      :: idir
    integer , intent(in ), dimension(3)        :: n
    real(rp), intent(in ), dimension(3)        :: dli
    real(rp), intent(in ), dimension(0:)       :: dzci
    real(rp), intent(in ), dimension(0:,0:,0:) :: ux ,uy ,uz
    real(rp), intent(out), dimension( :, :, :) :: vo
    real(rp) :: dxi,dyi
    integer :: i,j,k
    dxi = dli(1)
    dyi = dli(2)
    !$acc wait
    select case(idir)
    case(1)
      !$acc parallel loop collapse(3) default(present)
      !$OMP PARALLEL DO   COLLAPSE(3) DEFAULT(shared)
      do k=1,n(3)
        do j=1,n(2)
          do i=1,n(1)
            !
            ! x component of the vorticity at cell edge
            !
            vo(i,j,k) = (uz(i,j+1,k)-uz(i,j,k))*dyi     - (uy(i,j,k+1)-uy(i,j,k))*dzci(k)
          end do
        end do
      end do
    case(2)
      !$acc parallel loop collapse(3) default(present)
      !$OMP PARALLEL DO   COLLAPSE(3) DEFAULT(shared)
      do k=1,n(3)
        do j=1,n(2)
          do i=1,n(1)
            !
            ! y component of the vorticity at cell edge
            !
            vo(i,j,k) = (ux(i,j,k+1)-ux(i,j,k))*dzci(k) - (uz(i+1,j,k)-uz(i,j,k))*dxi
          end do
        end do
      end do
    case(3)
      !$acc parallel loop collapse(3) default(present)
      !$OMP PARALLEL DO   COLLAPSE(3) DEFAULT(shared)
      do k=1,n(3)
        do j=1,n(2)
          do i=1,n(1)
            !
            ! z component of the vorticity at cell edge
            !
            vo(i,j,k) = (uy(i+1,j,k)-uy(i,j,k))*dxi     - (ux(i,j+1,k)-ux(i,j,k))*dyi
          end do
        end do
      end do
    end select
    !$acc wait
  end subroutine vorticity_one_component
  !
  subroutine strain_rate(n,dli,dzci,dzfi,is_bound,lwm,ux,uy,uz,s0,sij)
    !
    ! Sij should be first computed at (or averaged to) cell center, then s0=sqrt(2SijSij)
    ! at cell center. This implementation is also adopted by Bae and Orlandi. Pedro averages
    ! SijSij to cell center first, then computes s0, which always leads to larger s0,
    ! especially when Sij at the cell edges have opposite signs. The current implementation
    ! avoids repetitive computation of derivatives, so it is much more efficient. Note that
    ! three seperate loops are required; the second and third loops cannot be combined.
    !
    ! when a wall model is applied, the first layer of cells is large that discontinuity
    ! appears near the wall, one-sided derivatives/averages should be used; averaging and
    ! differencing should not be done across the discontinuity.
    !
    implicit none
    integer , intent(in ), dimension(3)        :: n
    real(rp), intent(in ), dimension(3)        :: dli
    real(rp), intent(in ), dimension(0:)       :: dzci,dzfi
    logical , intent(in), dimension(0:1,3)     :: is_bound
    integer , intent(in), dimension(0:1,3)     :: lwm
    real(rp), intent(in ), dimension(0:,0:,0:) :: ux,uy,uz
    real(rp), intent(out), dimension(0:,0:,0:) :: s0
    real(rp), intent(out), dimension(0:,0:,0:,1:) :: sij
    real(rp) :: dxi,dyi,dzci_k,dzfi_k
    integer :: i,j,k
    !
    dxi = dli(1)
    dyi = dli(2)
    !
    ! compute s0 = sqrt(2*sij*sij), where sij = (1/2)(du_i/dx_j + du_j/dx_i)
    !
    !$acc parallel loop collapse(3) default(present) private(s11,s12,s13,s22,s23,s33)
    !$OMP PARALLEL DO   COLLAPSE(3) DEFAULT(shared)  PRIVATE(s11,s12,s13,s22,s23,s33)
    ! compute at cell edge
    do k = 0,n(3)
      do j = 0,n(2)
        do i = 0,n(1)
          sij(i,j,k,1) = 0.5_rp*((ux(i,j+1,k)-ux(i,j,k))*dyi     + (uy(i+1,j,k)-uy(i,j,k))*dxi)
          sij(i,j,k,2) = 0.5_rp*((ux(i,j,k+1)-ux(i,j,k))*dzci(k) + (uz(i+1,j,k)-uz(i,j,k))*dxi)
          sij(i,j,k,3) = 0.5_rp*((uy(i,j,k+1)-uy(i,j,k))*dzci(k) + (uz(i,j+1,k)-uz(i,j,k))*dyi)
        end do
      end do
    end do
    ! move to cell center
    do k = 1,n(3)
      do j = 1,n(2)
        do i = 1,n(1)
          sij(i,j,k,4) = 0.25_rp*(sij(i,j,k,1)+sij(i-1,j,k,1)+sij(i,j-1,k,1)+sij(i-1,j-1,k,1))
          sij(i,j,k,5) = 0.25_rp*(sij(i,j,k,2)+sij(i-1,j,k,2)+sij(i,j,k-1,2)+sij(i-1,j,k-1,2))
          sij(i,j,k,6) = 0.25_rp*(sij(i,j,k,3)+sij(i,j-1,k,3)+sij(i,j,k-1,3)+sij(i,j-1,k-1,3))
        end do
      end do
    end do
    ! one-sided differencing for the first off-wall layer
    if(is_bound(0,3).and.lwm(0,3)/=0) then
      do j = 1,n(2)
        do i = 1,n(1)
          sij(i,j,1,5) = 0.5_rp*(sij(i,j,1,2)+sij(i-1,j,1,2))
          sij(i,j,1,6) = 0.5_rp*(sij(i,j,1,3)+sij(i,j-1,1,3))
        end do
      end do
    end if
    if(is_bound(1,3).and.lwm(1,3)/=0) then
      do j = 1,n(2)
        do i = 1,n(1)
          sij(i,j,n(3),5) = 0.5_rp*(sij(i,j,n(3)-1,2)+sij(i-1,j,n(3)-1,2))
          sij(i,j,n(3),6) = 0.5_rp*(sij(i,j,n(3)-1,3)+sij(i-1,j,n(3)-1,3))
        end do
      end do
    end if
    ! compute at cell center
    do k = 1,n(3)
      do j = 1,n(2)
        do i = 1,n(1)
          sij(i,j,k,1) = (ux(i,j,k)-ux(i-1,j,k))*dxi
          sij(i,j,k,2) = (uy(i,j,k)-uy(i,j-1,k))*dyi
          sij(i,j,k,3) = (uz(i,j,k)-uz(i,j,k-1))*dzfi(k)
        end do
      end do
    end do
    !
    s0 = sij(:,:,:,1)**2 + sij(:,:,:,2)**2 + sij(:,:,:,3)**2 + &
        (sij(:,:,:,4)**2 + sij(:,:,:,5)**2 + sij(:,:,:,6)**2)*2._rp
    s0 = sqrt(2._rp*s0)
  end subroutine strain_rate
  !
  subroutine rotation_rate(n,dli,dzci,ux,uy,uz,ens)
    implicit none
    integer , intent(in ), dimension(3)        :: n
    real(rp), intent(in ), dimension(3)        :: dli
    real(rp), intent(in ), dimension(0:)       :: dzci
    real(rp), intent(in ), dimension(0:,0:,0:) :: ux,uy,uz
    real(rp), intent(out), dimension(1:,1:,1:) :: ens
    real(rp) :: e12,e13,e23
    real(rp) :: dxi,dyi
    integer :: i,j,k
    !
    ! compute wijwij, where wij = (1/2)(du_i/dx_j - du_j/dx_i)
    !
    dxi = dli(1)
    dyi = dli(2)
    !$acc parallel loop collapse(3) default(present) private(e12,e13,e23)
    !$OMP PARALLEL DO   COLLAPSE(3) DEFAULT(shared)  PRIVATE(e12,e13,e23)
    do k=1,n(3)
      do j=1,n(2)
        do i=1,n(1)
          e12 = .25_rp*( &
                        ((ux(i  ,j+1,k)-ux(i  ,j  ,k))*dyi - (uy(i+1,j  ,k)-uy(i  ,j  ,k))*dxi)**2 + &
                        ((ux(i  ,j  ,k)-ux(i  ,j-1,k))*dyi - (uy(i+1,j-1,k)-uy(i  ,j-1,k))*dxi)**2 + &
                        ((ux(i-1,j+1,k)-ux(i-1,j  ,k))*dyi - (uy(i  ,j  ,k)-uy(i-1,j  ,k))*dxi)**2 + &
                        ((ux(i-1,j  ,k)-ux(i-1,j-1,k))*dyi - (uy(i  ,j-1,k)-uy(i-1,j-1,k))*dxi)**2 &
                       )*.25_rp
          e13 = .25_rp*( &
                        ((ux(i  ,j,k+1)-ux(i  ,j,k  ))*dzci(k  ) - (uz(i+1,j,k  )-uz(i  ,j,k  ))*dxi)**2 + &
                        ((ux(i  ,j,k  )-ux(i  ,j,k-1))*dzci(k-1) - (uz(i+1,j,k-1)-uz(i  ,j,k-1))*dxi)**2 + &
                        ((ux(i-1,j,k+1)-ux(i-1,j,k  ))*dzci(k  ) - (uz(i  ,j,k  )-uz(i-1,j,k  ))*dxi)**2 + &
                        ((ux(i-1,j,k  )-ux(i-1,j,k-1))*dzci(k-1) - (uz(i  ,j,k-1)-uz(i-1,j,k-1))*dxi)**2 &
                       )*.25_rp
          e23 = .25_rp*( &
                        ((uy(i,j  ,k+1)-uy(i,j  ,k  ))*dzci(k  ) - (uz(i,j+1,k  )-uz(i,j  ,k  ))*dyi)**2 + &
                        ((uy(i,j  ,k  )-uy(i,j  ,k-1))*dzci(k-1) - (uz(i,j+1,k-1)-uz(i,j  ,k-1))*dyi)**2 + &
                        ((uy(i,j-1,k+1)-uy(i,j-1,k  ))*dzci(k  ) - (uz(i,j  ,k  )-uz(i,j-1,k  ))*dyi)**2 + &
                        ((uy(i,j-1,k  )-uy(i,j-1,k-1))*dzci(k-1) - (uz(i,j  ,k-1)-uz(i,j-1,k-1))*dyi)**2 &
                       )*.25_rp
          ens(i,j,k) =  2._rp*(e12+e13+e23)
        end do
      end do
    end do
  end subroutine rotation_rate
  !
  subroutine q_criterion(n,ens,str,qcr)
    implicit none
    integer , intent(in ), dimension(3)        :: n
    real(rp), intent(in ), dimension(1:,1:,1:) :: ens,str
    real(rp), intent(out), dimension(0:,0:,0:) :: qcr
    integer  :: i,j,k
    !
    !$acc parallel loop collapse(3) default(present)
    !$OMP PARALLEL DO   COLLAPSE(3) DEFAULT(shared)
    do k=1,n(3)
      do j=1,n(2)
        do i=1,n(1)
          qcr(i,j,k) = .5_rp*(ens(i,j,k)-str(i,j,k))
        end do
      end do
    end do
  end subroutine q_criterion
end module mod_post
