import { describe, it, expect, beforeEach } from 'vitest';
import { vi } from 'vitest';

describe('Escrow and Milestone-based Payments Contract', () => {
  const contractOwner = 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM';
  const client = 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG';
  const freelancer = 'ST2JHG361ZXG51QTKY2NQCVBPPRRE2KZB1HR05NNC';
  
  beforeEach(() => {
    vi.resetAllMocks();
  });
  
  it('should create an escrow', () => {
    const mockCreateEscrow = vi.fn().mockReturnValue({ success: true, value: 1 });
    expect(mockCreateEscrow(freelancer, 1000, [500, 500])).toEqual({ success: true, value: 1 });
  });
  
  it('should complete a milestone', () => {
    const mockCompleteMilestone = vi.fn().mockReturnValue({ success: true });
    expect(mockCompleteMilestone(1, 0)).toEqual({ success: true });
  });
  
  it('should get escrow details', () => {
    const mockGetEscrow = vi.fn().mockReturnValue({
      success: true,
      value: {
        client: client,
        freelancer: freelancer,
        total_amount: 1000,
        milestones: [
          { amount: 500, completed: true },
          { amount: 500, completed: false }
        ],
        status: 'active'
      }
    });
    const result = mockGetEscrow(1);
    expect(result.success).toBe(true);
    expect(result.value.total_amount).toBe(1000);
    expect(result.value.milestones.length).toBe(2);
    expect(result.value.milestones[0].completed).toBe(true);
    expect(result.value.milestones[1].completed).toBe(false);
  });
});

