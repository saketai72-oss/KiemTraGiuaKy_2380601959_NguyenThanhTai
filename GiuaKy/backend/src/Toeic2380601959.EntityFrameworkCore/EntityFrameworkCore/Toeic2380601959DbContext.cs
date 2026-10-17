using Abp.Zero.EntityFrameworkCore;
using Toeic2380601959.Authorization.Roles;
using Toeic2380601959.Authorization.Users;
using Toeic2380601959.MultiTenancy;
using Toeic2380601959.Toeic;
using Microsoft.EntityFrameworkCore;

namespace Toeic2380601959.EntityFrameworkCore;

public class Toeic2380601959DbContext : AbpZeroDbContext<Tenant, Role, User, Toeic2380601959DbContext>
{
    /* Define a DbSet for each entity of the application */
    public virtual DbSet<Exam> Exams { get; set; }
    public virtual DbSet<QuestionGroup> QuestionGroups { get; set; }
    public virtual DbSet<Question> Questions { get; set; }
    public virtual DbSet<QuestionOption> QuestionOptions { get; set; }
    public virtual DbSet<ExamAttempt> ExamAttempts { get; set; }
    public virtual DbSet<ExamAttemptAnswer> ExamAttemptAnswers { get; set; }

    public Toeic2380601959DbContext(DbContextOptions<Toeic2380601959DbContext> options)
        : base(options)
    {
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<QuestionGroup>()
            .HasOne(g => g.Exam)
            .WithMany(e => e.QuestionGroups)
            .HasForeignKey(g => g.ExamId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<Question>()
            .HasOne(q => q.Exam)
            .WithMany(e => e.Questions)
            .HasForeignKey(q => q.ExamId)
            .OnDelete(DeleteBehavior.Restrict);

        modelBuilder.Entity<Question>()
            .HasOne(q => q.QuestionGroup)
            .WithMany(g => g.Questions)
            .HasForeignKey(q => q.QuestionGroupId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<QuestionOption>()
            .HasOne(o => o.Question)
            .WithMany(q => q.Options)
            .HasForeignKey(o => o.QuestionId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<ExamAttempt>()
            .HasOne(a => a.Exam)
            .WithMany(e => e.ExamAttempts)
            .HasForeignKey(a => a.ExamId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<ExamAttemptAnswer>()
            .HasOne(ans => ans.ExamAttempt)
            .WithMany(a => a.Answers)
            .HasForeignKey(ans => ans.ExamAttemptId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<ExamAttemptAnswer>()
            .HasOne(ans => ans.Question)
            .WithMany(q => q.ExamAttemptAnswers)
            .HasForeignKey(ans => ans.QuestionId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
